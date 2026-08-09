import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../core/firebase/converters.dart';
import 'food_card.dart';
import 'protein_entry.dart';
import 'protein_slot.dart';

/// Thrown when a protein read/write fails. Screens convert this to
/// user-visible copy at the screen boundary — and that copy must obey the
/// feature's content rules (never "failed", never red).
class ProteinException implements Exception {
  const ProteinException(this.message);
  final String message;
  @override
  String toString() => 'ProteinException: $message';
}

/// Wraps the two protein collections.
///
/// The catalog is couple-scoped, so `coupleId` is a per-method parameter
/// (it is null until pairing completes) — same shape as
/// `SharedNotesRepository`. The log is user-scoped, so `userId` is bound in
/// the constructor — same shape as `WorkoutRepository`.
class ProteinRepository {
  ProteinRepository({required this._db, required this._userId});

  final FirebaseFirestore _db;
  final String _userId;
  static const _uuid = Uuid();
  static const _foodTimeFields = ['createdAt'];

  CollectionReference<Map<String, dynamic>> _foods(String coupleId) =>
      _db.collection('couples').doc(coupleId).collection('foods');

  CollectionReference<Map<String, dynamic>> get _log =>
      _db.collection('users').doc(_userId).collection('proteinLog');

  DocumentReference<Map<String, dynamic>> get _user =>
      _db.collection('users').doc(_userId);

  // ── Food catalog (shared between partners) ─────────────────────────────────

  Stream<List<FoodCard>> watchFoods(String coupleId) => _foods(coupleId)
      .orderBy('createdAt')
      .snapshots()
      .map((snap) => snap.docs.map(_decodeFood).toList());

  Future<void> createFood(
    String coupleId, {
    required String name,
    required int proteinGrams,
    required String icon,
  }) async {
    final card = FoodCard(
      id: _uuid.v4(),
      name: name.trim().isEmpty ? 'New food' : name.trim(),
      proteinGrams: proteinGrams.clamp(1, 120),
      icon: icon,
      createdAt: DateTime.now(),
    );
    final json = card.toJson()..remove('id');
    try {
      await _foods(coupleId)
          .doc(card.id)
          .set(dateTimesToTimestamps(json, _foodTimeFields));
    } on FirebaseException catch (e) {
      throw ProteinException(e.message ?? 'Could not save that card.');
    }
  }

  Future<void> updateFood(String coupleId, FoodCard card) async {
    try {
      await _foods(coupleId).doc(card.id).update({
        'name': card.name.trim().isEmpty ? 'New food' : card.name.trim(),
        'proteinGrams': card.proteinGrams.clamp(1, 120),
        'icon': card.icon,
      });
    } on FirebaseException catch (e) {
      throw ProteinException(e.message ?? 'Could not save that card.');
    }
  }

  /// Removes a card from the catalog. Past log entries are deliberately left
  /// alone — they carry their own snapshotted name and icon, so history and
  /// past weekly averages never change.
  Future<void> deleteFood(String coupleId, String foodId) async {
    try {
      await _foods(coupleId).doc(foodId).delete();
    } on FirebaseException catch (e) {
      throw ProteinException(e.message ?? 'Could not remove that card.');
    }
  }

  // ── Log (private to this user) ─────────────────────────────────────────────

  Stream<List<ProteinEntry>> watchDay(String day) => _log
      .where('day', isEqualTo: day)
      .snapshots()
      .map((snap) => snap.docs.map(_decodeEntry).toList());

  /// Inclusive range over `yyyy-MM-dd` keys. ISO dates sort lexicographically,
  /// so a string range is a correct date range.
  Stream<List<ProteinEntry>> watchWeek(String startDay, String endDay) => _log
      .where('day', isGreaterThanOrEqualTo: startDay)
      .where('day', isLessThanOrEqualTo: endDay)
      .snapshots()
      .map((snap) => snap.docs.map(_decodeEntry).toList());

  /// Logs one serving of [card] into [day]/[slot].
  ///
  /// Repeat taps merge: when an entry already exists with the same day, slot,
  /// cardId **and** unit, its `count` is incremented instead of adding a row.
  /// An entry whose amount was edited to a custom value no longer matches the
  /// card's stored grams, so it correctly stays separate.
  /// Returns the id of the entry that was created or incremented, so the undo
  /// toast can step exactly that row back down.
  ///
  /// [dayEntries] is the caller's already-streamed list for [day]. The merge
  /// candidate is found in it rather than by querying Firestore: a `get()`
  /// here would block on a network round-trip before any write happened, and
  /// the tap would visibly lag. Writes alone are applied to the local cache
  /// immediately, so resolving the merge in memory makes logging feel instant.
  Future<String> logCard(
    FoodCard card, {
    required String day,
    required ProteinSlot slot,
    required List<ProteinEntry> dayEntries,
  }) async {
    try {
      // Merge key: day + slot + cardId + unit. An entry whose amount was
      // edited to a custom value no longer matches, so it stays separate.
      ProteinEntry? existing;
      for (final e in dayEntries) {
        if (e.day == day &&
            e.slot == slot &&
            e.cardId == card.id &&
            e.unit == card.proteinGrams) {
          existing = e;
          break;
        }
      }

      if (existing != null) {
        await _log.doc(existing.id).update({
          'count': FieldValue.increment(1),
        });
        return existing.id;
      }

      final entry = ProteinEntry(
        id: _uuid.v4(),
        day: day,
        cardId: card.id,
        name: card.name,
        icon: card.icon,
        unit: card.proteinGrams,
        slot: slot,
      );
      await _log.doc(entry.id).set(entry.toJson()..remove('id'));
      return entry.id;
    } on FirebaseException catch (e) {
      throw ProteinException(e.message ?? 'Could not log that.');
    }
  }

  Future<void> updateEntry(ProteinEntry entry) async {
    try {
      await _log.doc(entry.id).update({
        'unit': entry.unit.clamp(1, 200),
        'count': entry.count.clamp(1, 20),
        'slot': entry.slot.name,
      });
    } on FirebaseException catch (e) {
      throw ProteinException(e.message ?? 'Could not save that change.');
    }
  }

  /// Steps a stacked row down by one, deleting it when the last serving goes.
  /// Also backs the undo action, so undo never removes a whole stack.
  Future<void> decrementEntry(ProteinEntry entry) async {
    if (entry.count <= 1) return deleteEntry(entry.id);
    try {
      await _log.doc(entry.id).update({'count': FieldValue.increment(-1)});
    } on FirebaseException catch (e) {
      throw ProteinException(e.message ?? 'Could not update that.');
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await _log.doc(entryId).delete();
    } on FirebaseException catch (e) {
      throw ProteinException(e.message ?? 'Could not remove that.');
    }
  }

  // ── Target ─────────────────────────────────────────────────────────────────

  Future<void> setTarget(int grams) async {
    try {
      await _user.update({'proteinTargetGrams': grams.clamp(20, 300)});
    } on FirebaseException catch (e) {
      throw ProteinException(e.message ?? 'Could not save your target.');
    }
  }

  // ── Decoders ───────────────────────────────────────────────────────────────

  FoodCard _decodeFood(QueryDocumentSnapshot<Map<String, dynamic>> snap) =>
      FoodCard.fromJson({
        ...timestampsToDateTimes(snap.data(), _foodTimeFields),
        'id': snap.id,
      });

  ProteinEntry _decodeEntry(QueryDocumentSnapshot<Map<String, dynamic>> snap) =>
      ProteinEntry.fromJson({...snap.data(), 'id': snap.id});
}
