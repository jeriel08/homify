import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/home/data/models/admin_stats_model.dart';
import 'package:homify/features/home/domain/repositories/admin_repository.dart';

class GetAdminStats {
  final AdminRepository repository;
  GetAdminStats(this.repository);

  /// The 'call' method makes the class callable like a function
  Future<Either<Failure, AdminStatsModel>> call() async {
    return await repository.getAdminStats();
  }
}
