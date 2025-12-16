import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/core/usecases/usecase.dart';
import 'package:homify/features/properties/domain/repositories/property_repository.dart';

class DeleteProperty implements UseCase<void, DeletePropertyParams> {
  final PropertyRepository repository;

  DeleteProperty(this.repository);

  @override
  Future<Either<Failure, void>> call(DeletePropertyParams params) async {
    return await repository.deleteProperty(params.propertyId, params.reason);
  }
}

class DeletePropertyParams extends Equatable {
  final String propertyId;
  final String reason;

  const DeletePropertyParams({required this.propertyId, required this.reason});

  @override
  List<Object?> get props => [propertyId, reason];
}
