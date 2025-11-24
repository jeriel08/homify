import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/admin/data/datasources/admin_remote_data_source.dart';
import 'package:homify/features/admin/data/models/admin_stats_model.dart';
import 'package:homify/features/admin/domain/entities/chart_data.dart';
import 'package:homify/features/admin/domain/entities/property_with_user.dart';
import 'package:homify/features/admin/domain/repositories/admin_repository.dart';
import 'package:homify/features/auth/domain/repositories/auth_repository.dart';
import 'package:homify/core/entities/user_entity.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  final AuthRepository authRepository;

  AdminRepositoryImpl({
    required this.remoteDataSource,
    required this.authRepository,
  });

  @override
  Future<Either<Failure, AdminStatsModel>> getAdminStats() async {
    try {
      final stats = await remoteDataSource.getAdminStats();
      return Right(stats);
    } catch (e) {
      // In a real app, you'd check for specific Firebase exceptions
      return const Left(ServerFailure('Failed to fetch admin stats.'));
    }
  }

  @override
  Future<Either<Failure, List<ChartData>>> getGraphData(String filter) async {
    try {
      final data = await remoteDataSource.getGraphData(filter);
      return Right(data);
    } catch (e) {
      return const Left(ServerFailure('Failed to fetch graph data.'));
    }
  }

  @override
  Stream<Either<Failure, List<PropertyWithUser>>> getPendingProperties() {
    try {
      // 1. Get the stream of properties
      final propertiesStream = remoteDataSource.getPendingPropertiesStream();

      // 2. Transform the stream: for each list, fetch users
      return propertiesStream.asyncMap((properties) async {
        try {
          // 3. Create a list of futures to get all users
          final userFutures = properties.map((prop) {
            return authRepository.getUser(prop.ownerUid);
          }).toList();

          // 4. Wait for all user fetches to complete
          final userResults = await Future.wait(userFutures);

          // 5. Combine properties and users
          final List<PropertyWithUser> detailedList = [];
          for (int i = 0; i < properties.length; i++) {
            final property = properties[i];
            final user = userResults[i]; // This is a UserEntity

            detailedList.add(PropertyWithUser(property: property, user: user));
          }
          // 6. Return the combined list, wrapped in Right()
          return Right(detailedList);
        } catch (e) {
          // 7. Return a Failure, wrapped in Right() for the stream
          return const Left(
            ServerFailure('Failed to fetch user data for properties.'),
          );
        }
      });
    } catch (e) {
      // Handle initial stream error
      return Stream.value(
        const Left(ServerFailure('Failed to stream pending properties.')),
      );
    }
  }

  @override
  Stream<Either<Failure, List<PropertyWithUser>>> getAllProperties() {
    try {
      final propertiesStream = remoteDataSource.getAllPropertiesStream();

      return propertiesStream.asyncMap((properties) async {
        try {
          final userFutures = properties.map((prop) {
            return authRepository.getUser(prop.ownerUid);
          }).toList();

          final userResults = await Future.wait(userFutures);

          final List<PropertyWithUser> detailedList = [];
          for (int i = 0; i < properties.length; i++) {
            final property = properties[i];
            final user = userResults[i];

            detailedList.add(PropertyWithUser(property: property, user: user));
          }
          return Right(detailedList);
        } catch (e) {
          return const Left(
            ServerFailure('Failed to fetch user data for properties.'),
          );
        }
      });
    } catch (e) {
      return Stream.value(
        const Left(ServerFailure('Failed to stream all properties.')),
      );
    }
  }

  @override
  Stream<Either<Failure, List<UserEntity>>> getAllUsers() {
    try {
      return remoteDataSource.getAllUsersStream().map((users) {
        return Right(users);
      });
    } catch (e) {
      return Stream.value(
        const Left(ServerFailure('Failed to stream all users.')),
      );
    }
  }
}
