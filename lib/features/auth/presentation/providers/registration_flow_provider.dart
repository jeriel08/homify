// lib/features/auth/presentation/providers/registration_flow_provider.dart
import 'package:flutter_riverpod/legacy.dart';
import 'package:homify/core/entities/user_entity.dart';

final justRegisteredProvider = StateProvider<bool>((ref) => false);
final justRegisteredAsProvider = StateProvider<AccountType?>((ref) => null);
final postLoginRedirectProvider = StateProvider<String?>((ref) => null);
