import 'package:homify/core/entities/user_entity.dart';

// We'll add error handling with 'Either' later to be more robust,
// but for now, we'll let it throw exceptions.

abstract class AuthRepository {
  /// Registers a new user with all their details.
  Future<UserEntity> registerUser(
    String email,
    String password,
    Map<String, dynamic> userData,
  );

  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> loginUser(String email, String password);
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> getUser(String uid);
  Future<void> logout();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> reauthenticate(String email, String currentPassword);
  Future<void> updatePassword(String newPassword);
}
