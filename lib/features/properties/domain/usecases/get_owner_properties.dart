import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/domain/repositories/property_repository.dart';

class GetOwnerProperties {
  final PropertyRepository repository;

  GetOwnerProperties(this.repository);

  Future<Either<Failure, List<PropertyEntity>>> call(String ownerUid) {
    return repository.getPropertiesByOwner(ownerUid);
  }
}
