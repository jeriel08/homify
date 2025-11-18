import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/core/entities/user_entity.dart';

class UserModel extends UserEntity {
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
  });

  /// Convert Firestore document → UserModel
  factory UserModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      accountType: _parseAccountType(data['account_type'] as String?),
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      birthday: data['birthday'] as String,
      gender: data['gender'] as String,
      mobile: data['mobile'] as String,
      email: data['email'] as String,
      createdAt: (data['created_at'] as Timestamp).toDate(),
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
    );
  }

  /// Convert UserModel → Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'account_type': accountType.name, // "tenant" or "owner"
      'first_name': firstName,
      'last_name': lastName,
      'birthday': birthday,
      'gender': gender,
      'mobile': mobile,
      'email': email,
      'created_at': FieldValue.serverTimestamp(),
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
