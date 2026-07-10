import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../core/firebase/converters.dart';
import 'exercise.dart';
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
  }) async {
    final exercise = Exercise(
      id: _uuid.v4(),
      name: name,
      bodyPart: bodyPart,
      createdAt: DateTime.now(),
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
    required List<WorkoutSet> sets,
  }) async {
    final id = _uuid.v4();
    final entry = WorkoutEntry(
      id: id,
      exerciseId: exerciseId,
      sets: sets,
      date: DateTime.now(),
    );
    final json = entry.toJson()
      ..remove('id')
      ..['sets'] = sets.map((s) => s.toJson()).toList();
    await _entries(exerciseId)
        .doc(id)
        .set(dateTimesToTimestamps(json, _entryTimeFields));
  }

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
}
