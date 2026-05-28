import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:couples_space/features/profile/data/user_profile.dart';
import 'package:couples_space/features/profile/data/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late UserRepository repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = UserRepository(firestore);
  });

  final sampleProfile = UserProfile(
    id: 'user-A',
    email: 'a@example.com',
    displayName: 'Alice',
    createdAt: DateTime.utc(2026, 1, 1),
  );

  test('createUser writes the doc and getUser reads it back', () async {
    await repo.createUser(sampleProfile);
    final loaded = await repo.getUser('user-A');
    expect(loaded, equals(sampleProfile));
  });

  test('updateDisplayName changes only the display name', () async {
    await repo.createUser(sampleProfile);
    await repo.updateDisplayName('user-A', 'Alicia');
    final loaded = await repo.getUser('user-A');
    expect(loaded!.displayName, 'Alicia');
    expect(loaded.email, 'a@example.com');
  });

  test('updateThemeMode persists the chosen mode', () async {
    await repo.createUser(sampleProfile);
    await repo.updateThemeMode('user-A', AppThemeMode.dark);
    final loaded = await repo.getUser('user-A');
    expect(loaded!.themeMode, AppThemeMode.dark);
  });

  test('setCoupleId backfills coupleId', () async {
    await repo.createUser(sampleProfile);
    await repo.setCoupleId('user-A', 'couple-1');
    final loaded = await repo.getUser('user-A');
    expect(loaded!.coupleId, 'couple-1');
  });

  test('watchUser emits updates as the document changes', () async {
    await repo.createUser(sampleProfile);
    final stream = repo.watchUser('user-A');
    final first = await stream.first;
    expect(first!.displayName, 'Alice');
  });
}
