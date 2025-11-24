import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:homify/core/entities/user_entity.dart';

class UserModel extends UserEntity {
  final String? school;
  final Map<String, dynamic>? preferences;
  final String? occupation;

  const UserModel({
    required super.uid,
    required super.accountType,
    required super.firstName,
    required super.lastName,
    required super.birthday,
    required super.gender,
    required super.mobile,
    required super.email,
    required super.createdAt,
    required super.onboardingComplete,
    required super.emailVerified,
    super.isBanned,
    super.bannedAt,
    super.bannedBy,
    this.school,
    this.preferences,
    this.occupation,
  });

  /// Convert Firestore document → UserModel
  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    debugPrint('PARSING USER: ${doc.id}');
    debugPrint(' - Raw email_verified: ${data['email_verified']}');
    debugPrint(' - Raw onboarding_complete: ${data['onboarding_complete']}');

    return UserModel(
      uid: doc.id,
      accountType: _parseAccountType(data['account_type'] as String?),
      firstName: data['first_name'] as String? ?? '',
      lastName: data['last_name'] as String? ?? '',
      birthday: data['birthday'] as String? ?? '',
      gender: data['gender'] as String? ?? '',
      mobile: data['mobile'] as String? ?? '',
      email: data['email'] as String? ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      onboardingComplete: data['onboarding_complete'] as bool? ?? false,
      school: data['school'] as String?,
      preferences: data['preferences'] as Map<String, dynamic>?,
      emailVerified: data['email_verified'] as bool? ?? false,
      occupation: data['occupation'] as String?,
      isBanned: data['is_banned'] as bool? ?? false,
      bannedAt: (data['banned_at'] as Timestamp?)?.toDate(),
      bannedBy: data['banned_by'] as String?,
    );
  }

  @override
  String get fullName => '$firstName $lastName';

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      accountType: entity.accountType,
      firstName: entity.firstName,
      lastName: entity.lastName,
      birthday: entity.birthday,
      gender: entity.gender,
      mobile: entity.mobile,
      email: entity.email,
      createdAt: entity.createdAt,
      onboardingComplete: entity.onboardingComplete,
      emailVerified: entity.emailVerified,
    );
  }

  /// Convert UserModel → Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'account_type': accountType.name,
      'first_name': firstName,
      'last_name': lastName,
      'birthday': birthday,
      'gender': gender,
      'mobile': mobile,
      'email': email,
      'created_at': FieldValue.serverTimestamp(),
      'onboarding_complete': onboardingComplete,
      'school': school,
      'preferences': preferences,
      'email_verified': emailVerified,
      'occupation': occupation,
      'is_banned': isBanned,
      'banned_at': bannedAt != null ? Timestamp.fromDate(bannedAt!) : null,
      'banned_by': bannedBy,
    };
  }

  static AccountType _parseAccountType(String? raw) {
    if (raw == null) return AccountType.tenant;
    return AccountType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => AccountType.tenant,
    );
  }
}
