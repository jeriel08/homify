import 'dart:io';
import 'package:homify/core/entities/property_entity.dart';
import 'package:homify/features/properties/data/datasources/property_remote_data_source.dart';
import 'package:homify/features/properties/data/models/property_model.dart';
import 'package:homify/features/properties/domain/repositories/property_repository.dart';

class PropertyRepositoryImpl implements PropertyRepository {
  final PropertyRemoteDataSource remoteDataSource;

  PropertyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PropertyEntity> addProperty(
    PropertyEntity propertyData,
    List<File> images,
  ) async {
    try {
      // 1. Convert the Entity (app data) to a Model (data data)
      // We cast it to our PropertyModel
      final propertyModel = PropertyModel(
        id: propertyData.id, // This will be replaced by the data source
        ownerUid: propertyData.ownerUid,
        name: propertyData.name,
        description: propertyData.description,
        type: propertyData.type,
        rentChargeMethod: propertyData.rentChargeMethod,
        rentAmount: propertyData.rentAmount,
        amenities: propertyData.amenities,
        latitude: propertyData.latitude,
        longitude: propertyData.longitude,
        imageUrls: [], // Will be filled by data source
        createdAt: propertyData.createdAt,
      );

      // 2. Call the data source
      final newPropertyModel = await remoteDataSource.addProperty(
        propertyModel,
        images,
      );

      // 3. Return the result as an Entity
      return newPropertyModel;
    } catch (e) {
      throw Exception('Repository error: ${e.toString()}');
    }
  }
}
