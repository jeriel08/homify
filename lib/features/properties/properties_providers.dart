import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/properties/data/datasources/property_remote_data_source.dart';
import 'package:homify/features/properties/data/repositories/property_repository_impl.dart';
import 'package:homify/features/properties/domain/repositories/property_repository.dart';
import 'package:homify/features/properties/domain/usecases/add_property.dart';
import 'package:homify/features/properties/domain/usecases/get_property_by_id.dart';
import 'package:homify/features/properties/domain/usecases/update_property.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';

// --- DATA LAYER ---

/// Provides the implementation of the PropertyRemoteDataSource
///
/// This is where you'd replace YOUR_CLOUD_NAME and YOUR_UPLOAD_PRESET
/// from the file above.
final propertyRemoteDataSourceProvider = Provider<PropertyRemoteDataSource>((
  ref,
) {
  // We can pass in the Firestore instance directly
  // and CloudinaryPublic is initialized inside the Impl
  return PropertyRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

// --- DOMAIN LAYER ---

/// Provides the implementation of the PropertyRepository
final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  // Watch the data source provider
  final remoteDataSource = ref.watch(propertyRemoteDataSourceProvider);
  return PropertyRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provides the AddProperty Use Case
final addPropertyUseCaseProvider = Provider<AddProperty>((ref) {
  // Watch the repository provider
  final repository = ref.watch(propertyRepositoryProvider);
  return AddProperty(repository: repository);
});

/// Provides the GetPropertyById Use Case
final getPropertyByIdUseCaseProvider = Provider<GetPropertyById>((ref) {
  final repository = ref.watch(propertyRepositoryProvider);
  return GetPropertyById(repository);
});

/// Provides the UpdateProperty Use Case
final updatePropertyUseCaseProvider = Provider<UpdateProperty>((ref) {
  final repository = ref.watch(propertyRepositoryProvider);
  return UpdateProperty(repository);
});

/// Provides all verified properties for sharing/browsing
final verifiedPropertiesProvider = FutureProvider<List<PropertyEntity>>((
  ref,
) async {
  final repository = ref.watch(propertyRepositoryProvider);
  final result = await repository.getVerifiedProperties();
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (properties) => properties,
  );
});
