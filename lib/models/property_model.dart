// lib/models/property_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// ---------------------------------------------------------------------------
/// 1. Enums
/// ---------------------------------------------------------------------------

/// How the owner charges rent
enum RentChargeMethod {
  perPerson, // e.g. ₱1,500 per person
  perBed, // e.g. ₱8,000 per room / bedspace
  perRoom,
  perUnit; // flat monthly rent (used for whole-house/apartment)

  String get displayName {
    return switch (this) {
      RentChargeMethod.perPerson => 'Per Person',
      RentChargeMethod.perBed => 'Per Bed',
      RentChargeMethod.perRoom => 'Per Room',
      RentChargeMethod.perUnit => 'Per Unit',
    };
  }

  static RentChargeMethod? fromString(String? raw) {
    if (raw == null) return null;
    return RentChargeMethod.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => RentChargeMethod.perUnit,
    );
  }
}

/// The 5 possible property types (same as step_property_type.dart)
enum PropertyType {
  bedspacer,
  room,
  house,
  apartment,
  dormitory;

  String get displayName {
    return switch (this) {
      PropertyType.bedspacer => 'Bedspace',
      PropertyType.room => 'Room for Rent',
      PropertyType.house => 'House for Rent',
      PropertyType.apartment => 'Apartment Unit',
      PropertyType.dormitory => 'Dormitory',
    };
  }

  static PropertyType? fromString(String? raw) {
    if (raw == null) return null;
    return PropertyType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => PropertyType.bedspacer,
    );
  }
}

/// ---------------------------------------------------------------------------
/// 2. Property model
/// ---------------------------------------------------------------------------

class Property {
  // -------------------------------------------------------------------------
  // Core identifiers
  // -------------------------------------------------------------------------
  final String id; // Firestore document ID (auto-generated)
  final String ownerUid; // UID of the owner (AppUser.uid)

  // -------------------------------------------------------------------------
  // Basic info (from step_property_info)
  // -------------------------------------------------------------------------
  final String name;
  final String description;

  // -------------------------------------------------------------------------
  // Type & pricing
  // -------------------------------------------------------------------------
  final PropertyType type; // from step_property_type
  final RentChargeMethod rentChargeMethod;
  final double rentAmount; // numeric value (e.g. 1500.0)

  // -------------------------------------------------------------------------
  // Amenities (array of strings – you can later replace with an enum list)
  // -------------------------------------------------------------------------
  final List<String> amenities;

  // -------------------------------------------------------------------------
  // Location (Google-Maps ready)
  // -------------------------------------------------------------------------
  final double latitude;
  final double longitude;
  // Firestore stores GeoPoint, but we expose lat/lng for easy UI work
  GeoPoint get geoPoint => GeoPoint(latitude, longitude);

  // -------------------------------------------------------------------------
  // Images – URLs stored in Firestore (actual files live in Firebase Storage)
  // -------------------------------------------------------------------------
  final List<String>
  imageUrls; // e.g. ["https://firebasestorage.../img1.jpg", ...]

  // -------------------------------------------------------------------------
  // Timestamps
  // -------------------------------------------------------------------------
  final DateTime createdAt;
  final DateTime? updatedAt; // optional, set on edits

  // -------------------------------------------------------------------------
  // Constructor
  // -------------------------------------------------------------------------
  const Property({
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

  // -------------------------------------------------------------------------
  // Firestore ↔ Dart
  // -------------------------------------------------------------------------
  factory Property.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final geo = data['location'] as GeoPoint?;
    return Property(
      id: doc.id,
      ownerUid: data['owner_uid'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      type: PropertyType.fromString(data['type'] as String?)!,
      rentChargeMethod: RentChargeMethod.fromString(
        data['rent_charge_method'] as String?,
      )!,
      rentAmount: (data['rent_amount'] as num).toDouble(),
      amenities: List<String>.from(data['amenities'] ?? []),
      latitude: geo?.latitude ?? 0.0,
      longitude: geo?.longitude ?? 0.0,
      imageUrls: List<String>.from(data['image_urls'] ?? []),
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: data['updated_at'] != null
          ? (data['updated_at'] as Timestamp).toDate()
          : null,
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
      'location': geoPoint,
      'image_urls': imageUrls,
      'createdat': FieldValue.serverTimestamp(),
      if (updatedAt != null) 'updated_at': Timestamp.fromDate(updatedAt!),
    };
  }

  // -------------------------------------------------------------------------
  // Helper: copyWith for immutable updates
  // -------------------------------------------------------------------------
  Property copyWith({
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
  }) {
    return Property(
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
    );
  }
}
