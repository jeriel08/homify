import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:homify/features/profile/domain/entities/user_profile_entity.dart';
import 'package:homify/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfile>> getUserProfile(String userId) async {
    try {
      final profile = await remoteDataSource.getUserProfile(userId);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Either<Failure, Stream<UserProfile>> getUserProfileStream(String userId) {
    try {
      final stream = remoteDataSource.getUserProfileStream(userId);
      return Right(stream);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await remoteDataSource.updateProfile(userId, updates);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> banUser(String userId, String bannedBy) async {
    try {
      await remoteDataSource.banUser(userId, bannedBy);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> unbanUser(String userId) async {
    try {
      await remoteDataSource.unbanUser(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
