import 'package:homify/features/auth/domain/repositories/auth_repository.dart';

class SendPasswordResetEmailUseCase {
  final AuthRepository repository;

  SendPasswordResetEmailUseCase(this.repository);

  Future<void> call(String email) async {
    return repository.sendPasswordResetEmail(email);
  }
}
