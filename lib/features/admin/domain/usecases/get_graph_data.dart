import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/admin/domain/repositories/admin_repository.dart';
import 'package:homify/features/admin/domain/entities/chart_data.dart';

class GetGraphData {
  final AdminRepository repository;
  GetGraphData(this.repository);

  /// The 'call' method makes the class callable like a function
  Future<Either<Failure, List<ChartData>>> call(String filter) async {
    return await repository.getGraphData(filter);
  }
}
