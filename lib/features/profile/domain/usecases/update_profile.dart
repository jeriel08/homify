import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/profile/domain/repositories/profile_repository.dart';

class UpdateProfile {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  Future<Either<Failure, void>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(params.userId, params.updates);
  }
}

class UpdateProfileParams {
  final String userId;
  final Map<String, dynamic> updates;

  const UpdateProfileParams({required this.userId, required this.updates});
}
