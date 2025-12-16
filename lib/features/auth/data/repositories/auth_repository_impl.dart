import 'package:firebase_auth/firebase_auth.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/features/auth/domain/repositories/auth_repository.dart';
import 'package:homify/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> getUser(String uid) async {
    try {
      // You will need to add `getUser` to your AuthRemoteDataSource
      final userModel = await remoteDataSource.getUser(uid);
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception('Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

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

  @override
  Future<UserEntity> loginUser(String email, String password) async {
    try {
      final userModel = await remoteDataSource.loginUser(email, password);
      return userModel;
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = 'No account found with this email.';
          break;
        case 'wrong-password':
          msg = 'Incorrect password.';
          break;
        case 'invalid-email':
          msg = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          msg = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          msg = 'Too many attempts. Try again later.';
          break;
        default:
          msg = e.message ?? 'Authentication failed.';
      }
      throw Exception('Auth Error: $msg');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception('Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } on FirebaseAuthException catch (e) {
      throw Exception('Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      // The remoteDataSource returns a UserModel, which *is* a UserEntity
      final userModel = await remoteDataSource.signInWithGoogle();
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw Exception('Auth Error: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  @override
  Future<void> reauthenticate(String email, String currentPassword) async {
    try {
      await remoteDataSource.reauthenticate(email, currentPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception('Auth Error: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    try {
      await remoteDataSource.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception('Auth Error: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<UserEntity>> searchUsers(String query) async {
    try {
      final userModels = await remoteDataSource.searchUsers(query);
      return userModels;
    } on FirebaseAuthException catch (e) {
      throw Exception('Auth Error: ${e.message}');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
