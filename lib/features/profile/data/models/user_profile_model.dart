import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/features/profile/domain/entities/user_profile_entity.dart';

/// Data model for UserProfile
class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.role,
    required super.createdAt,
    super.isBanned,
    super.bannedAt,
    super.bannedBy,
    super.schoolId,
    super.ownerId,
    super.photoUrl,
  });

  /// Create model from Firestore document
  factory UserProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserProfileModel(
      uid: doc.id,
      firstName: data['first_name'] as String? ?? '',
      lastName: data['last_name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: _parseAccountType(data['account_type'] as String?),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isBanned: data['is_banned'] as bool? ?? false,
      bannedAt: (data['banned_at'] as Timestamp?)?.toDate(),
      bannedBy: data['banned_by'] as String?,
      schoolId: data['school'] as String?,
      ownerId: data['owner_id'] as String?,
      photoUrl: data['photo_url'] as String?,
    );
  }

  /// Create model from entity
  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      uid: entity.uid,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      role: entity.role,
      createdAt: entity.createdAt,
      isBanned: entity.isBanned,
      bannedAt: entity.bannedAt,
      bannedBy: entity.bannedBy,
      schoolId: entity.schoolId,
      ownerId: entity.ownerId,
      photoUrl: entity.photoUrl,
    );
  }

  static AccountType _parseAccountType(String? raw) {
    if (raw == null) return AccountType.tenant;
    return AccountType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => AccountType.tenant,
    );
  }
}
