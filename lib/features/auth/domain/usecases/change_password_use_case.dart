import 'package:homify/features/auth/domain/repositories/auth_repository.dart';

/// Use case for changing the user's password.
/// Requires reauthentication with current password before updating.
class ChangePasswordUseCase {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  /// Changes the user's password.
  /// [email] - The user's email for reauthentication
  /// [currentPassword] - The user's current password
  /// [newPassword] - The new password to set
  Future<void> call({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    // Step 1: Reauthenticate with current credentials
    await repository.reauthenticate(email, currentPassword);

    // Step 2: Update to new password
    await repository.updatePassword(newPassword);
  }
}
