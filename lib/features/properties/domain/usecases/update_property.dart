import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/domain/repositories/property_repository.dart';

class UpdatePropertyParams {
  final String propertyId;
  final String? name;
  final String? description;
  final PropertyType? type;
  final double? rentAmount;
  final RentChargeMethod? rentChargeMethod;
  final List<String>? amenities;
  final List<String>? imageUrls;

  UpdatePropertyParams({
    required this.propertyId,
    this.name,
    this.description,
    this.type,
    this.rentAmount,
    this.rentChargeMethod,
    this.amenities,
    this.imageUrls,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (description != null) map['description'] = description;
    if (type != null) map['type'] = type!.name;
    if (rentAmount != null) map['rent_amount'] = rentAmount;
    if (rentChargeMethod != null) {
      map['rent_charge_method'] = rentChargeMethod!.name;
    }
    if (amenities != null) map['amenities'] = amenities;
    if (imageUrls != null) map['image_urls'] = imageUrls;
    return map;
  }
}

class UpdateProperty {
  final PropertyRepository repository;

  UpdateProperty(this.repository);

  Future<Either<Failure, PropertyEntity>> call(
    UpdatePropertyParams params,
  ) async {
    return await repository.updateProperty(params.propertyId, params.toMap());
  }
}
