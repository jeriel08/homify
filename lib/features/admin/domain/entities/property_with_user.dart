import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/core/entities/user_entity.dart';

class PropertyWithUser {
  final PropertyEntity property;
  final UserEntity user;

  const PropertyWithUser({required this.property, required this.user});
}
