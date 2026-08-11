import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../core/firebase/converters.dart';
import 'exercise.dart';
import 'workout_day.dart';
import 'workout_entry.dart';
import 'workout_set.dart';

class WorkoutRepository {
  WorkoutRepository({required this._db, required this._userId});

  final FirebaseFirestore _db;
  final String _userId;
  static const _uuid = Uuid();
  static const _exerciseTimeFields = ['createdAt'];
  static const _entryTimeFields = ['date'];

  CollectionReference<Map<String, dynamic>> get _exercises =>
      _db.collection('users').doc(_userId).collection('exercises');

  CollectionReference<Map<String, dynamic>> get _days =>
      _db.collection('users').doc(_userId).collection('days');

  CollectionReference<Map<String, dynamic>> _entries(String exerciseId) =>
      _exercises.doc(exerciseId).collection('entries');

  // ── Exercises ──────────────────────────────────────────────────────────────

  Stream<List<Exercise>> watchExercises({bool includeArchived = false}) {
    Query<Map<String, dynamic>> q = _exercises;
    if (!includeArchived) q = q.where('isArchived', isEqualTo: false);
    return q
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(_decodeExercise).toList());
  }

  Stream<Exercise?> watchExercise(String exerciseId) {
    return _exercises.doc(exerciseId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return _decodeExercise(snap);
    });
  }

  Future<void> createExercise({
    required String name,
    required String bodyPart,
    String? dayId,
  }) async {
    final exercise = Exercise(
      id: _uuid.v4(),
      name: name,
      bodyPart: bodyPart,
      createdAt: DateTime.now(),
      dayIds: dayId != null ? [dayId] : [],
    );
    final json = exercise.toJson()..remove('id');
    await _exercises
        .doc(exercise.id)
        .set(dateTimesToTimestamps(json, _exerciseTimeFields));
  }

  Future<void> archiveExercise(String exerciseId) =>
      _exercises.doc(exerciseId).update({'isArchived': true});

  Future<void> unarchiveExercise(String exerciseId) =>
      _exercises.doc(exerciseId).update({'isArchived': false});

  Future<void> deleteExercise(String exerciseId) async {
    final entriesSnap = await _entries(exerciseId).get();
    final batch = _db.batch();
    for (final doc in entriesSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_exercises.doc(exerciseId));
    await batch.commit();
  }

  // ── Days ───────────────────────────────────────────────────────────────────

  Stream<List<WorkoutDay>> watchDays() => _days
      .orderBy('order')
      .snapshots()
      .map((snap) => snap.docs.map(_decodeDay).toList());

  Future<void> createDay() async {
    final snap = await _days.get();
    final n = snap.size;
    await _days.doc(_uuid.v4()).set({'name': 'Day ${n + 1}', 'order': n});
  }

  Future<void> deleteDay(String dayId) async {
    final exercisesSnap =
        await _exercises.where('dayIds', arrayContains: dayId).get();
    final daysSnap = await _days.orderBy('order').get();
    final batch = _db.batch();
    for (final doc in exercisesSnap.docs) {
      batch.update(doc.reference, {
        'dayIds': FieldValue.arrayRemove([dayId]),
      });
    }
    batch.delete(_days.doc(dayId));
    var newOrder = 0;
    for (final doc in daysSnap.docs) {
      if (doc.id == dayId) continue;
      batch.update(doc.reference, {'order': newOrder});
      newOrder++;
    }
    await batch.commit();
  }

  Future<void> renameDay(String dayId, String name) =>
      _days.doc(dayId).update({'name': name});

  Future<void> toggleExerciseInDay(
      String exerciseId, String dayId, {required bool add}) =>
      _exercises.doc(exerciseId).update({
        'dayIds': add
            ? FieldValue.arrayUnion([dayId])
            : FieldValue.arrayRemove([dayId]),
      });

  // ── Entries ────────────────────────────────────────────────────────────────

  Stream<List<WorkoutEntry>> watchEntries(String exerciseId) {
    return _entries(exerciseId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_decodeEntry).toList());
  }

  Stream<List<WorkoutEntry>> watchEntriesForWeek(
    String exerciseId,
    DateTime start,
    DateTime end,
  ) {
    return _entries(exerciseId)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
            isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .map((snap) => snap.docs.map(_decodeEntry).toList());
  }

  Future<void> createEntry({
    required String exerciseId,
    List<WorkoutSet> sets = const [],
    int? durationMinutes,
    double? distanceKm,
    double? speed,
    int? resistance,
  }) async {
    final id = _uuid.v4();
    final entry = WorkoutEntry(
      id: id,
      exerciseId: exerciseId,
      sets: sets,
      date: DateTime.now(),
      durationMinutes: durationMinutes,
      distanceKm: distanceKm,
      speed: speed,
      resistance: resistance,
    );
    final json = entry.toJson()
      ..remove('id')
      ..['sets'] = sets.map((s) => s.toJson()).toList();
    await _entries(exerciseId)
        .doc(id)
        .set(dateTimesToTimestamps(json, _entryTimeFields));
  }

  /// Overwrites a logged entry's measurements, leaving its `date` untouched —
  /// editing a mistake shouldn't move the session to today.
  ///
  /// Endurance fields are written even when null so clearing a value actually
  /// removes it; `update` ignores keys you omit, which would silently keep a
  /// stale distance or speed.
  Future<void> updateEntry({
    required String exerciseId,
    required String entryId,
    List<WorkoutSet> sets = const [],
    int? durationMinutes,
    double? distanceKm,
    double? speed,
    int? resistance,
  }) =>
      _entries(exerciseId).doc(entryId).update({
        'sets': sets.map((s) => s.toJson()).toList(),
        'durationMinutes': durationMinutes,
        'distanceKm': distanceKm,
        'speed': speed,
        'resistance': resistance,
      });

  Future<void> deleteEntry(String exerciseId, String entryId) =>
      _entries(exerciseId).doc(entryId).delete();

  // ── Decoders ───────────────────────────────────────────────────────────────

  Exercise _decodeExercise(DocumentSnapshot<Map<String, dynamic>> snap) {
    return Exercise.fromJson({
      ...timestampsToDateTimes(snap.data()!, _exerciseTimeFields),
      'id': snap.id,
    });
  }

  WorkoutEntry _decodeEntry(DocumentSnapshot<Map<String, dynamic>> snap) {
    return WorkoutEntry.fromJson({
      ...timestampsToDateTimes(snap.data()!, _entryTimeFields),
      'id': snap.id,
    });
  }

  WorkoutDay _decodeDay(DocumentSnapshot<Map<String, dynamic>> snap) =>
      WorkoutDay.fromJson({...snap.data()!, 'id': snap.id});
}
