import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/admin/data/models/admin_stats_model.dart';
import 'package:homify/features/admin/domain/entities/chart_data.dart';
import 'package:homify/features/admin/domain/entities/property_with_user.dart';
import 'package:homify/core/entities/user_entity.dart';

abstract class AdminRepository {
  /// Gets the KPI stats for the admin dashboard
  Future<Either<Failure, AdminStatsModel>> getAdminStats();

  /// Gets the registration data for the admin chart
  Future<Either<Failure, List<ChartData>>> getGraphData(String filter);
  Stream<Either<Failure, List<PropertyWithUser>>> getPendingProperties();
  Stream<Either<Failure, List<PropertyWithUser>>> getAllProperties();
  Stream<Either<Failure, List<UserEntity>>> getAllUsers();
}
