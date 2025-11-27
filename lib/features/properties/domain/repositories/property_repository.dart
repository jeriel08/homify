import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';

abstract class PropertyRepository {
  Future<PropertyEntity> addProperty(
    PropertyEntity propertyData,
    List<File> images,
  );

  Future<Either<Failure, List<PropertyEntity>>> getVerifiedProperties();
  Future<Either<Failure, List<PropertyEntity>>> getPropertiesByOwner(
    String ownerUid,
  );

  Future<Either<Failure, PropertyEntity>> getPropertyById(String id);

  Future<Either<Failure, PropertyEntity>> updateProperty(
    String propertyId,
    Map<String, dynamic> updates,
  );

  Future<Either<Failure, void>> deleteProperty(
    String propertyId,
    String reason,
  );

  Future<Either<Failure, List<PropertyEntity>>> searchProperties({
    String? query,
    PropertyType? type,
  });
}
