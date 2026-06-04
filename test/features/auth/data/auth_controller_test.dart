import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:couples_space/features/auth/data/auth_controller.dart';
import 'package:couples_space/features/profile/data/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore firestore;
  late AuthController controller;

  setUp(() {
    auth = MockFirebaseAuth();
    firestore = FakeFirebaseFirestore();
    controller = AuthController(auth, UserRepository(firestore));
  });

  test('signUp creates auth user and user doc with display name', () async {
    await controller.signUp(
      email: 'a@example.com',
      password: 'password123',
      displayName: 'Alice',
    );
    expect(auth.currentUser, isNotNull);
    final uid = auth.currentUser!.uid;
    final users = await firestore.collection('users').doc(uid).get();
    expect(users.data()!['email'], 'a@example.com');
    expect(users.data()!['displayName'], 'Alice');
    expect(users.data()!['coupleId'], isNull);
  });

  test('signIn calls Firebase signIn', () async {
    auth = MockFirebaseAuth(
      mockUser: MockUser(uid: 'u1', email: 'a@example.com'),
    );
    controller = AuthController(auth, UserRepository(firestore));
    await controller.signIn(email: 'a@example.com', password: 'p');
    expect(auth.currentUser!.uid, 'u1');
  });
}
