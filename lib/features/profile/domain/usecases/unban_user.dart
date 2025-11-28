import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/profile/domain/repositories/profile_repository.dart';

class UnbanUser {
  final ProfileRepository repository;

  UnbanUser(this.repository);

  Future<Either<Failure, void>> call(String userId) async {
    return await repository.unbanUser(userId);
  }
}
