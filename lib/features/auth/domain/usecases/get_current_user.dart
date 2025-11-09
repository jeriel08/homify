import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser({required this.repository});

  /// The 'call' method allows us to call the class instance as a function
  Future<UserEntity?> call() async {
    return await repository.getCurrentUser();
  }
}
