import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/home/data/datasources/admin_remote_data_source.dart';
import 'package:homify/features/home/data/models/admin_stats_model.dart';
import 'package:homify/features/home/domain/repositories/admin_repository.dart';
import 'package:homify/features/home/presentation/providers/admin_provider.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

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
}
