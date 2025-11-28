import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/profile/domain/entities/user_profile_entity.dart';
import 'package:homify/features/profile/domain/repositories/profile_repository.dart';

/// Use case for getting user profile stream with real-time updates
class GetUserProfileStream {
  final ProfileRepository repository;

  GetUserProfileStream(this.repository);

  Either<Failure, Stream<UserProfile>> call(String userId) {
    return repository.getUserProfileStream(userId);
  }
}
