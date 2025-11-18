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
}
