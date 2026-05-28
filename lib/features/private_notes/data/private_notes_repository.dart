import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couples_space/core/firebase/converters.dart';

import '../../shared_notes/data/note.dart';

class PrivateNotesRepository {
  PrivateNotesRepository(this._firestore, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final FirebaseFirestore _firestore;
  final DateTime Function() _now;
  static const _timeFields = ['createdAt', 'updatedAt'];

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _firestore.collection('users').doc(userId).collection('privateNotes');

  Stream<List<Note>> watchNotes(String userId) {
    return _col(userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _decode(d, userId)).toList());
  }

  Future<String> createNote({
    required String userId,
    required String title,
    required String body,
  }) async {
    final now = _now();
    final doc = _col(userId).doc();
    final data = dateTimesToTimestamps({
      'title': title,
      'body': body,
      'authorId': userId,
      'createdAt': now.toUtc().toIso8601String(),
      'updatedAt': now.toUtc().toIso8601String(),
    }, _timeFields);
    await doc.set(data);
    return doc.id;
  }

  Future<void> updateNote({
    required String userId,
    required String noteId,
    required String title,
    required String body,
  }) {
    return _col(userId).doc(noteId).update({
      'title': title,
      'body': body,
      'updatedAt': Timestamp.fromDate(_now()),
    });
  }

  Future<void> deleteNote({required String userId, required String noteId}) {
    return _col(userId).doc(noteId).delete();
  }

  Note _decode(
    QueryDocumentSnapshot<Map<String, dynamic>> snap,
    String userId,
  ) {
    final data = snap.data();
    final converted = timestampsToDateTimes(data, _timeFields);
    return Note.fromJson({
      ...converted,
      'id': snap.id,
      'authorId': data['authorId'] ?? userId,
    });
  }
}
