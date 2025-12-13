import 'package:homify/features/properties/data/models/property_model.dart';

enum RentChargeMethod { perMonth }

enum PropertyType { bedspacer, room, house, apartment, dormitory }

class PropertyEntity {
  final String id;
  final String ownerUid;
  final String name;
  final String description;
  final PropertyType type;
  final RentChargeMethod rentChargeMethod;
  final double rentAmount;
  final List<String> amenities;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;
  final int favoritesCount;

  const PropertyEntity({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.description,
    required this.type,
    required this.rentChargeMethod,
    required this.rentAmount,
    required this.amenities,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.createdAt,
    required this.isVerified,
    this.updatedAt,
    this.favoritesCount = 0,
  });

  PropertyModel copyWith({
    String? id,
    String? ownerUid,
    String? name,
    String? description,
    PropertyType? type,
    RentChargeMethod? rentChargeMethod,
    double? rentAmount,
    List<String>? amenities,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    int? favoritesCount,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      rentChargeMethod: rentChargeMethod ?? this.rentChargeMethod,
      rentAmount: rentAmount ?? this.rentAmount,
      amenities: amenities ?? this.amenities,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      favoritesCount: favoritesCount ?? this.favoritesCount,
    );
  }
}
