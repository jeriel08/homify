import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/core/entities/user_entity.dart';

// This class combines the two pieces of data
class PendingPropertyDetails {
  final PropertyEntity property;
  final UserEntity user; // Or use UserModel here

  const PendingPropertyDetails({required this.property, required this.user});
}
