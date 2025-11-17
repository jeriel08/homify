import 'package:flutter_riverpod/flutter_riverpod.dart';
// --- UPDATE IMPORTS ---
import 'package:homify/features/admin/domain/entities/pending_property_details.dart';
import 'package:homify/features/admin/presentation/providers/admin_provider.dart'; // Or wherever adminRepositoryProvider is

// --- THIS IS YOUR NEW PROVIDER ---
final pendingPropertiesProvider = StreamProvider<List<PendingPropertyDetails>>((
  ref,
) {
  final adminRepo = ref.watch(adminRepositoryProvider);

  // 1. Call the new repository method
  final streamEither = adminRepo.getPendingProperties();

  // 2. Handle the Either<> inside the stream
  return streamEither.map((either) {
    return either.fold(
      (failure) => [], // On failure, return an empty list
      (details) => details, // On success, return the list
    );
  });
});
