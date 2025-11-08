import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:homify/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:homify/features/auth/domain/repositories/auth_repository.dart';
import 'package:homify/features/auth/domain/usecases/register_user.dart';

// --- DATA LAYER ---
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

// --- DOMAIN LAYER ---
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: remoteDataSource);
});

final registerUserUseCaseProvider = Provider<RegisterUser>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUser(repository: repository);
});
