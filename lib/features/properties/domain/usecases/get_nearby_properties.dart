import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/core/usecases/usecase.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/domain/repositories/property_repository.dart';

class GetNearbyProperties
    implements UseCase<List<PropertyEntity>, GetNearbyPropertiesParams> {
  final PropertyRepository repository;

  GetNearbyProperties(this.repository);

  @override
  Future<Either<Failure, List<PropertyEntity>>> call(
    GetNearbyPropertiesParams params,
  ) async {
    // 1. Get all verified properties
    final result = await repository.getVerifiedProperties();

    return result.map((properties) {
      // 2. Calculate distance and sort
      final sortedProperties = List<PropertyEntity>.from(properties);

      sortedProperties.sort((a, b) {
        final distanceA = Geolocator.distanceBetween(
          params.latitude,
          params.longitude,
          a.latitude,
          a.longitude,
        );
        final distanceB = Geolocator.distanceBetween(
          params.latitude,
          params.longitude,
          b.latitude,
          b.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      // 3. Return top 5
      return sortedProperties.take(5).toList();
    });
  }
}

class GetNearbyPropertiesParams extends Equatable {
  final double latitude;
  final double longitude;

  const GetNearbyPropertiesParams({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}
