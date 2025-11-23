import 'dart:io';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/domain/repositories/property_repository.dart';

class AddProperty {
  final PropertyRepository repository;

  AddProperty({required this.repository});

  /// Call this use case as a function
  Future<PropertyEntity> call({
    required PropertyEntity propertyData,
    required List<File> images,
  }) {
    return repository.addProperty(propertyData, images);
  }
}
