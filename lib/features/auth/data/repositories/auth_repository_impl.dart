import 'package:firebase_auth/firebase_auth.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/features/auth/domain/repositories/auth_repository.dart';
import 'package:homify/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> registerUser(
    String email,
    String password,
    Map<String, dynamic> userData,
  ) async {
    try {
      // Call the "Firebase Guy"
      final userModel = await remoteDataSource.registerUser(
        email,
        password,
        userData,
      );

      // The "UserModel" IS-A "UserEntity" (thanks to 'extends'),
      // so we can return it directly. This is the magic of inheritance!
      return userModel;
    } on FirebaseAuthException catch (e) {
      // Here you can convert a data-layer exception
      // into a domain-layer failure/exception
      throw Exception('Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }
}
