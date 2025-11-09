import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/features/auth/domain/repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser({required this.repository});

  /// The 'call' method allows us to call the class instance as a function
  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    // Delegates the "how" to the repository.
    return repository.loginUser(email, password);
  }
}
