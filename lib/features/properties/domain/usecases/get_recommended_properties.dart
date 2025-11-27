import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/core/usecases/usecase.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/domain/repositories/property_repository.dart';

class GetRecommendedProperties
    implements UseCase<List<PropertyEntity>, GetRecommendedPropertiesParams> {
  final PropertyRepository repository;

  GetRecommendedProperties(this.repository);

  @override
  Future<Either<Failure, List<PropertyEntity>>> call(
    GetRecommendedPropertiesParams params,
  ) async {
    final result = await repository.getVerifiedProperties();

    return result.map((properties) {
      return properties.where((property) {
        // 1. Check Budget
        if (property.rentAmount < params.minBudget ||
            property.rentAmount > params.maxBudget) {
          return false;
        }

        // 2. Check Dealbreakers (Amenities)
        // All dealbreakers must be present in property amenities
        for (final dealbreaker in params.dealbreakers) {
          if (!property.amenities.contains(dealbreaker)) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }
}

class GetRecommendedPropertiesParams extends Equatable {
  final double minBudget;
  final double maxBudget;
  final List<String> dealbreakers;

  const GetRecommendedPropertiesParams({
    required this.minBudget,
    required this.maxBudget,
    required this.dealbreakers,
  });

  @override
  List<Object> get props => [minBudget, maxBudget, dealbreakers];
}
