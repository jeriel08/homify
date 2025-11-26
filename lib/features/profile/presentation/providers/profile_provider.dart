import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:homify/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:homify/features/profile/domain/entities/user_profile_entity.dart';
import 'package:homify/features/profile/domain/repositories/profile_repository.dart';
import 'package:homify/features/profile/domain/usecases/ban_user.dart';
import 'package:homify/features/profile/domain/usecases/get_user_profile.dart';
import 'package:homify/features/profile/domain/usecases/get_user_profile_stream.dart';
import 'package:homify/features/profile/domain/usecases/unban_user.dart';
import 'package:homify/features/profile/domain/usecases/update_profile.dart';

/// Data source provider
final profileDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

/// Repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.watch(profileDataSourceProvider),
  );
});

/// Use cases providers
final getUserProfileUseCaseProvider = Provider<GetUserProfile>((ref) {
  return GetUserProfile(ref.watch(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfile>((ref) {
  return UpdateProfile(ref.watch(profileRepositoryProvider));
});

final banUserUseCaseProvider = Provider<BanUser>((ref) {
  return BanUser(ref.watch(profileRepositoryProvider));
});

final unbanUserUseCaseProvider = Provider<UnbanUser>((ref) {
  return UnbanUser(ref.watch(profileRepositoryProvider));
});

final getUserProfileStreamUseCaseProvider = Provider<GetUserProfileStream>((
  ref,
) {
  return GetUserProfileStream(ref.watch(profileRepositoryProvider));
});

/// User profile provider (Future-based, one-time fetch)
final userProfileProvider = FutureProvider.family.autoDispose((
  ref,
  String userId,
) async {
  final useCase = ref.watch(getUserProfileUseCaseProvider);
  final result = await useCase(userId);

  return result.fold(
    (failure) => throw Exception(failure.message),
    (profile) => profile,
  );
});

/// User profile stream provider for real-time updates
final userProfileStreamProvider = StreamProvider.family
    .autoDispose<UserProfile, String>((ref, String userId) {
      final useCase = ref.watch(getUserProfileStreamUseCaseProvider);
      final result = useCase(userId);

      return result.fold(
        (failure) => Stream.error(Exception(failure.message)),
        (stream) => stream,
      );
    });
