import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/features/auth/domain/repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle({required this.repository});

  /// The 'call' method allows us to call the class instance as a function
  Future<UserEntity> call() async {
    return repository.signInWithGoogle();
  }
}
