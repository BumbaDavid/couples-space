import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/converters.dart';
import 'user_profile.dart';

class UserRepository {
  UserRepository(this._firestore);

  final FirebaseFirestore _firestore;
  static const _timeFields = ['createdAt'];

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('users');

  Stream<UserProfile?> watchUser(String userId) {
    return _col.doc(userId).snapshots().map(_decode);
  }

  Future<UserProfile?> getUser(String userId) async {
    final snap = await _col.doc(userId).get();
    return _decode(snap);
  }

  Future<void> createUser(UserProfile profile) async {
    final json = profile.toJson()..remove('id');
    final encoded = dateTimesToTimestamps(json, _timeFields);
    await _col.doc(profile.id).set(encoded);
  }

  Future<void> updateDisplayName(String userId, String displayName) {
    return _col.doc(userId).update({'displayName': displayName});
  }

  Future<void> updateThemeMode(String userId, AppThemeMode mode) {
    return _col.doc(userId).update({'themeMode': mode.name});
  }

  Future<void> setCoupleId(String userId, String coupleId) {
    return _col.doc(userId).update({'coupleId': coupleId});
  }

  UserProfile? _decode(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data();
    if (data == null) return null;
    final converted = timestampsToDateTimes(data, _timeFields);
    return UserProfile.fromJson({...converted, 'id': snap.id});
  }
}
