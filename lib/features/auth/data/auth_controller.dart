import 'package:firebase_auth/firebase_auth.dart';

import '../../profile/data/user_profile.dart';
import '../../profile/data/user_repository.dart';

class AuthController {
  AuthController(this._auth, this._users);

  final FirebaseAuth _auth;
  final UserRepository _users;

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = cred.user!;

    await _users.createUser(
      UserProfile(
        id: user.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();
}
