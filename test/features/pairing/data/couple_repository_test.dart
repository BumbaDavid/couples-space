import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:couples_space/features/pairing/data/couple_repository.dart';
import 'package:couples_space/features/pairing/data/invite_code.dart';
import 'package:couples_space/features/pairing/data/invite_code_repository.dart';
import 'package:couples_space/features/profile/data/user_profile.dart';
import 'package:couples_space/features/profile/data/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late CoupleRepository couples;
  late InviteCodeRepository invites;
  late UserRepository users;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    couples = CoupleRepository(firestore);
    invites = InviteCodeRepository(firestore);
    users = UserRepository(firestore);

    await users.createUser(
      UserProfile(
        id: 'user-A',
        email: 'a@example.com',
        displayName: 'Alice',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );
    await users.createUser(
      UserProfile(
        id: 'user-B',
        email: 'b@example.com',
        displayName: 'Bob',
        createdAt: DateTime.utc(2026, 1, 1),
      ),
    );
    await invites.create(
      InviteCode(
        code: 'ABC234',
        createdBy: 'user-A',
        createdAt: DateTime.utc(2026, 1, 1),
        expiresAt: DateTime.utc(2030, 1, 1),
      ),
    );
  });

  test('claimInvite creates couple, sets B coupleId, deletes invite', () async {
    final coupleId = await couples.claimInvite(
      code: 'ABC234',
      currentUserId: 'user-B',
    );

    final couple = await couples.findCoupleForUser('user-B');
    expect(couple, isNotNull);
    expect(couple!.id, coupleId);
    expect(couple.memberIds, containsAll(['user-A', 'user-B']));

    final bProfile = await users.getUser('user-B');
    expect(bProfile!.coupleId, coupleId);

    expect(await invites.get('ABC234'), isNull);

    // A is not yet backfilled — by design.
    final aProfile = await users.getUser('user-A');
    expect(aProfile!.coupleId, isNull);
  });

  test('claimInvite throws when code is missing', () async {
    expect(
      () => couples.claimInvite(code: 'MISSING', currentUserId: 'user-B'),
      throwsA(isA<PairingException>()),
    );
  });

  test('claimInvite throws when claimant is the creator', () async {
    expect(
      () => couples.claimInvite(code: 'ABC234', currentUserId: 'user-A'),
      throwsA(isA<PairingException>()),
    );
  });

  test('claimInvite throws when code is expired', () async {
    await invites.create(
      InviteCode(
        code: 'OLD234',
        createdBy: 'user-A',
        createdAt: DateTime.utc(2020, 1, 1),
        expiresAt: DateTime.utc(2020, 1, 2),
      ),
    );
    expect(
      () => couples.claimInvite(code: 'OLD234', currentUserId: 'user-B'),
      throwsA(isA<PairingException>()),
    );
  });

  test('findCoupleForUser returns null when not paired', () async {
    expect(await couples.findCoupleForUser('user-A'), isNull);
  });
}
