import 'dart:io';
import 'package:homify/core/entities/property_entity.dart';

abstract class PropertyRepository {
  Future<PropertyEntity> addProperty(
    PropertyEntity propertyData,
    List<File> images,
  );

  // You would also add:
  // Future<List<PropertyEntity>> getAllProperties();
}
