enum AccountType { tenant, owner, admin }

class UserEntity {
  final String uid;
  final AccountType accountType;
  final String firstName;
  final String lastName;
  final String birthday; // "YYYY-MM-DD"
  final String gender; // "male" | "female" | "other"
  final String mobile; // "+63..."
  final String email;
  final DateTime createdAt;
  final String? photoUrl;
  final bool onboardingComplete;
  final bool emailVerified;
  final bool isBanned;
  final DateTime? bannedAt;
  final String? bannedBy; // Admin UID who banned the user

  String get fullName => '$firstName $lastName';

  const UserEntity({
    required this.uid,
    required this.accountType,
    required this.firstName,
    required this.lastName,
    required this.birthday,
    required this.gender,
    required this.mobile,
    required this.email,
    required this.createdAt,
    required this.onboardingComplete,
    this.emailVerified = false,
    this.isBanned = false,
    this.bannedAt,
    this.bannedBy,
    this.photoUrl,
  });
}
