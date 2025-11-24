import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/domain/repositories/property_repository.dart';

class GetPropertyById {
  final PropertyRepository repository;

  GetPropertyById(this.repository);

  Future<Either<Failure, PropertyEntity>> call(String id) {
    return repository.getPropertyById(id);
  }
}
