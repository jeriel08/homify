// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum AccountType { tenant, owner }

class AppUser {
  final String uid;
  final AccountType accountType;
  final String firstName;
  final String lastName;
  final String birthday; // "YYYY-MM-DD"
  final String gender; // "male" | "female" | "other"
  final String mobile; // "+63..."
  final String email;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.accountType,
    required this.firstName,
    required this.lastName,
    required this.birthday,
    required this.gender,
    required this.mobile,
    required this.email,
    required this.createdAt,
  });

  /// Convert Firestore document → AppUser
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AppUser(
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

  /// Convert AppUser → Map for Firestore
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
