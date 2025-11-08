enum RentChargeMethod { perPerson, perBed, perRoom, perUnit }

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
    this.updatedAt,
  });
}
