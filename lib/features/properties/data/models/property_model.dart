import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';

class PropertyModel extends PropertyEntity {
  const PropertyModel({
    required super.id,
    required super.ownerUid,
    required super.name,
    required super.description,
    required super.type,
    required super.rentChargeMethod,
    required super.rentAmount,
    required super.amenities,
    required super.latitude,
    required super.longitude,
    required super.imageUrls,
    required super.createdAt,
    required super.isVerified,
    super.updatedAt,
    required int favoritesCount,
    super.status,
    super.rejectionReason,
  });

  // Firestore stores GeoPoint, but our Entity just cares about lat/lng
  GeoPoint get geoPoint => GeoPoint(latitude, longitude);

  factory PropertyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final geo = data['location'] as GeoPoint?;
    final isVerified = data['is_verified'] ?? false;

    // Parse status from Firestore, with backward compatibility
    PropertyStatus status;
    final statusString = data['status'] as String?;
    if (statusString != null) {
      status = PropertyStatus.values.firstWhere(
        (e) => e.name == statusString,
        orElse: () =>
            isVerified ? PropertyStatus.approved : PropertyStatus.pending,
      );
    } else {
      // Backward compatibility: derive status from is_verified
      status = isVerified ? PropertyStatus.approved : PropertyStatus.pending;
    }

    return PropertyModel(
      id: doc.id,
      ownerUid: data['owner_uid'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      // We can use the enums from the entity file
      type: PropertyType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => PropertyType.bedspacer,
      ),
      rentChargeMethod: RentChargeMethod.values.firstWhere(
        (e) => e.name == data['rent_charge_method'],
        orElse: () => RentChargeMethod.perMonth,
      ),
      rentAmount: (data['rent_amount'] as num).toDouble(),
      amenities: List<String>.from(data['amenities'] ?? []),
      latitude: geo?.latitude ?? 0.0,
      longitude: geo?.longitude ?? 0.0,
      imageUrls: List<String>.from(data['image_urls'] ?? []),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as Timestamp).toDate()
          : null,
      isVerified: isVerified,
      favoritesCount: data['favorites_count'] ?? 0,
      status: status,
      rejectionReason: data['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'owner_uid': ownerUid,
      'name': name,
      'description': description,
      'type': type.name,
      'rent_charge_method': rentChargeMethod.name,
      'rent_amount': rentAmount,
      'amenities': amenities,
      'location': geoPoint, // Use the getter here
      'image_urls': imageUrls,
      'created_at': FieldValue.serverTimestamp(),
      'is_verified': isVerified,
      'favorites_count': favoritesCount,
      'status': status.name,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
      if (updatedAt != null) 'updated_at': Timestamp.fromDate(updatedAt!),
    };
  }
}
