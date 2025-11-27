import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
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
        isVerified: propertyData.isVerified,
        favoritesCount: propertyData.favoritesCount,
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

  @override
  Future<Either<Failure, List<PropertyEntity>>> getVerifiedProperties() async {
    try {
      final properties = await remoteDataSource.getVerifiedProperties();
      return Right(properties);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PropertyEntity>>> getPropertiesByOwner(
    String ownerUid,
  ) async {
    try {
      final properties = await remoteDataSource.getPropertiesByOwner(ownerUid);
      return Right(properties);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PropertyEntity>> getPropertyById(String id) async {
    try {
      final property = await remoteDataSource.getPropertyById(id);
      return Right(property);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PropertyEntity>> updateProperty(
    String propertyId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final property = await remoteDataSource.updateProperty(
        propertyId,
        updates,
      );
      return Right(property);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
