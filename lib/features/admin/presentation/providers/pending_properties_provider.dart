import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/admin/domain/entities/property_with_user.dart';
import 'package:homify/features/admin/presentation/providers/admin_provider.dart';

final pendingPropertiesProvider = StreamProvider<List<PropertyWithUser>>((ref) {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return adminRepo.getPendingProperties().map((either) {
    return either.fold((failure) => [], (properties) => properties);
  });
});
