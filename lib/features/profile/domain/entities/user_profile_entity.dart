import 'package:homify/core/entities/user_entity.dart';

/// User profile entity with complete user information
class UserProfile {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final AccountType role;
  final DateTime createdAt;
  final bool isBanned;
  final DateTime? bannedAt;
  final String? bannedBy;
  final String? schoolId;
  final String? ownerId;
  final String? photoUrl;
  final String? mobile;
  final String? school;
  final String? occupation;
  final Map<String, dynamic>? preferences;

  const UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.createdAt,
    this.isBanned = false,
    this.bannedAt,
    this.bannedBy,
    this.schoolId,
    this.ownerId,
    this.photoUrl,
    this.mobile,
    this.school,
    this.occupation,
    this.preferences,
  });

  String get fullName => '$firstName $lastName';

  String get displayRole {
    switch (role) {
      case AccountType.admin:
        return 'Administrator';
      case AccountType.owner:
        return 'Property Owner';
      case AccountType.tenant:
        return 'Tenant';
    }
  }

  String get displayOccupation {
    if (role == AccountType.admin) {
      return 'Administrator';
    }
    return occupation ?? 'N/A';
  }
}
