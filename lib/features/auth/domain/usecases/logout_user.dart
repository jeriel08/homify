import 'package:homify/features/auth/domain/repositories/auth_repository.dart';

class LogoutUser {
  final AuthRepository repository;

  LogoutUser({required this.repository});

  /// The 'call' method allows us to call the class instance as a function
  Future<void> call() async {
    return repository.logout();
  }
}
