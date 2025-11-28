import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/profile/domain/entities/user_profile_entity.dart';

/// Repository interface for profile operations
abstract class ProfileRepository {
  /// Get user profile by ID
  Future<Either<Failure, UserProfile>> getUserProfile(String userId);

  /// Get user profile stream for real-time updates
  Either<Failure, Stream<UserProfile>> getUserProfileStream(String userId);

  /// Update user profile (firstName, lastName)
  Future<Either<Failure, void>> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  );

  /// Ban a user (admin only)
  Future<Either<Failure, void>> banUser(String userId, String bannedBy);

  /// Unban a user (admin only)
  Future<Either<Failure, void>> unbanUser(String userId);
}
