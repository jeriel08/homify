import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/features/auth/domain/repositories/auth_repository.dart';

class RegisterUser {
  final AuthRepository repository;

  RegisterUser({required this.repository});

  /// The 'call' method allows us to call the class instance as a function
  /// e.g. `registerUserUseCase(email, password, data)`
  Future<UserEntity> call({
    required String email,
    required String password,
    required Map<String, dynamic> userData,
  }) async {
    // This one line is the entire use case.
    // It delegates the "how" to the repository.
    return repository.registerUser(email, password, userData);
  }
}
