import 'package:couples_space/core/firebase/firebase_providers.dart';
import 'package:couples_space/features/auth/data/auth_controller.dart';
import 'package:couples_space/features/profile/data/user_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(
    ref.watch(firebaseAuthProvider),
    ref.watch(userRepositoryProvider),
  );
});
