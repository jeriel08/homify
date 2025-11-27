import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/properties/domain/usecases/delete_property.dart';
import 'package:homify/features/properties/properties_providers.dart';

final deletePropertyUseCaseProvider = Provider<DeleteProperty>((ref) {
  final repository = ref.watch(propertyRepositoryProvider);
  return DeleteProperty(repository);
});
