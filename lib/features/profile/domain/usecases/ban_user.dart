import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/profile/domain/repositories/profile_repository.dart';

class BanUser {
  final ProfileRepository repository;

  BanUser(this.repository);

  Future<Either<Failure, void>> call(BanUserParams params) async {
    return await repository.banUser(
      params.userId,
      params.bannedBy,
      params.reason,
    );
  }
}

class BanUserParams {
  final String userId;
  final String bannedBy; // Admin UID
  final String reason;

  const BanUserParams({
    required this.userId,
    required this.bannedBy,
    required this.reason,
  });
}
