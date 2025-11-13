// lib/features/auth/presentation/providers/user_role_provider.dart

// import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:homify/core/entities/user_entity.dart';

enum AppUserRole { guest, tenant, owner, admin }

final userRoleProvider = Provider<AppUserRole>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.whenData((user) {
        if (user == null) return AppUserRole.guest;

        return switch (user.accountType) {
          AccountType.tenant => AppUserRole.tenant,
          AccountType.owner => AppUserRole.owner,
          AccountType.admin => AppUserRole.admin,
        };
      }).value ??
      AppUserRole.guest;
});
