import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:couples_space/features/pairing/data/invite_code.dart';
import 'package:couples_space/features/pairing/data/invite_code_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InviteCodeRepository repo;

  setUp(() {
    repo = InviteCodeRepository(FakeFirebaseFirestore());
  });

  test('generateCode returns 6 chars from the unambiguous alphabet', () {
    const allowed = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    for (var i = 0; i < 20; i++) {
      final code = repo.generateCode();
      expect(code.length, 6);
      for (final c in code.split('')) {
        expect(
          allowed.contains(c),
          isTrue,
          reason: '$code contains forbidden char $c',
        );
      }
    }
  });

  test('create and get round-trip', () async {
    final invite = InviteCode(
      code: 'ABC234',
      createdBy: 'user-A',
      createdAt: DateTime.utc(2026, 1, 1),
      expiresAt: DateTime.utc(2026, 1, 2),
    );
    await repo.create(invite);
    final loaded = await repo.get('ABC234');
    expect(loaded, equals(invite));
  });

  test('delete removes the doc', () async {
    final invite = InviteCode(
      code: 'ABC234',
      createdBy: 'user-A',
      createdAt: DateTime.utc(2026, 1, 1),
      expiresAt: DateTime.utc(2026, 1, 2),
    );
    await repo.create(invite);
    await repo.delete('ABC234');
    expect(await repo.get('ABC234'), isNull);
  });
}
