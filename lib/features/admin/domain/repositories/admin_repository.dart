import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/admin/data/models/admin_stats_model.dart';
import 'package:homify/features/admin/presentation/providers/admin_provider.dart';

abstract class AdminRepository {
  /// Gets the KPI stats for the admin dashboard
  Future<Either<Failure, AdminStatsModel>> getAdminStats();

  /// Gets the registration data for the admin chart
  Future<Either<Failure, List<ChartData>>> getGraphData(String filter);
}
