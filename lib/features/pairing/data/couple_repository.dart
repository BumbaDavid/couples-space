import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../core/firebase/converters.dart';
import 'couple.dart';

class PairingException implements Exception {
  PairingException(this.reason);
  final String reason;
  @override
  String toString() => 'PairingException: $reason';
}

class CoupleRepository {
  CoupleRepository(this._firestore, {Uuid? uuid, DateTime Function()? now})
    : _uuid = uuid ?? const Uuid(),
      _now = now ?? DateTime.now;

  final FirebaseFirestore _firestore;
  final Uuid _uuid;
  final DateTime Function() _now;
  static const _timeFields = ['createdAt'];
  static const _inviteTimeFields = ['createdAt', 'expiresAt'];

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('couples');

  Stream<Couple?> watchCoupleById(String coupleId) {
    return _col.doc(coupleId).snapshots().map(_decode);
  }

  Stream<Couple?> watchCoupleForUser(String userId) {
    return _col
        .where('memberIds', arrayContains: userId)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : _decode(snap.docs.first));
  }

  Future<Couple?> findCoupleForUser(String userId) async {
    final query = await _col
        .where('memberIds', arrayContains: userId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return _decode(query.docs.first);
  }

  Future<String> claimInvite({
    required String code,
    required String currentUserId,
  }) async {
    final inviteRef = _firestore.collection('inviteCodes').doc(code);
    final inviteSnap = await inviteRef.get();
    final inviteData = inviteSnap.data();
    if (inviteData == null) {
      throw PairingException('Invite code not found');
    }
    final inviteJson = timestampsToDateTimes(inviteData, _inviteTimeFields);
    final createdBy = inviteJson['createdBy'] as String;
    final expiresAt = DateTime.parse(inviteJson['expiresAt'] as String);
    if (createdBy == currentUserId) {
      throw PairingException('Cannot claim your own invite');
    }
    if (expiresAt.isBefore(_now())) {
      throw PairingException('Invite code has expired');
    }

    final newCoupleId = _uuid.v4();
    final batch = _firestore.batch();
    batch.set(
      _col.doc(newCoupleId),
      dateTimesToTimestamps({
        'memberIds': [createdBy, currentUserId],
        'createdAt': _now().toUtc().toIso8601String(),
      }, _timeFields),
    );
    batch.update(_firestore.collection('users').doc(currentUserId), {
      'coupleId': newCoupleId,
    });
    batch.delete(inviteRef);
    await batch.commit();
    return newCoupleId;
  }

  Couple? _decode(DocumentSnapshot<Map<String, dynamic>> snap) {
    final data = snap.data();
    if (data == null) return null;
    final converted = timestampsToDateTimes(data, _timeFields);
    return Couple.fromJson({
      ...converted,
      'id': snap.id,
      'memberIds': List<String>.from(converted['memberIds'] as List),
    });
  }
}
