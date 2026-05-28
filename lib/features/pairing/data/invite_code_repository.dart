import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/converters.dart';
import 'invite_code.dart';

class InviteCodeRepository {
  InviteCodeRepository(this._firestore, {Random? random})
    : _random = random ?? Random.secure();

  final FirebaseFirestore _firestore;
  final Random _random;
  static const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const _timeFields = ['createdAt', 'expiresAt'];

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('inviteCodes');

  String generateCode() {
    final buffer = StringBuffer();
    for (var i = 0; i < 6; i++) {
      buffer.write(_alphabet[_random.nextInt(_alphabet.length)]);
    }
    return buffer.toString();
  }

  Future<void> create(InviteCode invite) async {
    final json = invite.toJson()..remove('code');
    final encoded = dateTimesToTimestamps(json, _timeFields);
    await _col.doc(invite.code).set(encoded);
  }

  Future<InviteCode?> get(String code) async {
    final snap = await _col.doc(code).get();
    final data = snap.data();
    if (data == null) return null;
    final converted = timestampsToDateTimes(data, _timeFields);
    return InviteCode.fromJson({...converted, 'code': snap.id});
  }

  Future<void> delete(String code) {
    return _col.doc(code).delete();
  }
}
