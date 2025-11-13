import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/features/auth/presentation/pages/landing_page.dart';
import 'package:homify/features/auth/presentation/pages/login_page.dart';
import 'package:homify/features/auth/presentation/pages/registration_page.dart';
import 'package:homify/features/auth/presentation/pages/owner_success_page.dart';
import 'package:homify/features/auth/presentation/pages/tenant_success_page.dart';
import 'package:homify/features/home/presentation/pages/account_page.dart';
import 'package:homify/features/home/presentation/pages/home_page.dart';
import 'package:homify/features/properties/presentation/pages/add_property_page.dart';
import 'package:homify/features/properties/presentation/pages/property_success_page.dart';
import 'package:homify/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:homify/features/auth/presentation/providers/user_role_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authInit = ref.watch(authStateProvider);
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (authInit.isLoading) {
        return null; // Don't redirect yet
      }

      final authState = ref.read(authStateProvider);
      final role = ref.read(userRoleProvider);

      final isLoggedIn = authState.value != null;
      final isGuest = role == AppUserRole.guest;

      final path = state.matchedLocation;
      final isAuthPage = ['/', '/login', '/register'].contains(path);
      final isSuccessPage = [
        '/tenant-success',
        '/owner-success',
      ].contains(path);

      // === 1. ALLOW SUCCESS PAGES ONLY IF COMING FROM REGISTRATION ===
      if (isSuccessPage) {
        // Check if we just registered (use a flag or query param)
        final fromRegistration =
            state.uri.queryParameters['from'] == 'registration';
        if (!fromRegistration && isLoggedIn) {
          // Already logged in → skip success page
          return role == AppUserRole.owner ? '/create-property' : '/home';
        }
        return null; // Allow success page
      }

      // === 2. GUEST RULES ===
      if (isGuest) {
        if (path == '/home') return null;
        if (isAuthPage) return null;
        return '/home'; // Force guest to home
      }

      // === 3. LOGGED IN RULES ===
      if (isLoggedIn) {
        if (isAuthPage) return '/home';
        if (path == '/home' && role == AppUserRole.owner) {
          return '/create-property';
        }
        return null;
      }

      // === 4. NOT LOGGED IN & NOT GUEST ===
      if (!isAuthPage && !isSuccessPage) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LandingPage()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationPage(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountPage(),
      ),
      GoRoute(
        path: '/create-property',
        builder: (context, state) => const AddPropertyPage(),
      ),
      GoRoute(
        path: '/property-success',
        builder: (context, state) => const PropertySuccessPage(),
      ),
      GoRoute(
        path: '/tenant-success',
        builder: (context, state) => const TenantRegistrationSuccess(),
      ),
      GoRoute(
        path: '/owner-success',
        builder: (context, state) => const OwnerRegistrationSuccess(),
      ),
      // Add admin route later
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('404: ${state.error}'))),
  );
});
