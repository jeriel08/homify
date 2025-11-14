import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/core/widgets/loading_screen.dart';
import 'package:homify/features/auth/presentation/pages/landing_page.dart';
import 'package:homify/features/auth/presentation/pages/login_page.dart';
import 'package:homify/features/auth/presentation/pages/registration_page.dart';
import 'package:homify/features/auth/presentation/pages/owner_success_page.dart';
import 'package:homify/features/auth/presentation/pages/tenant_success_page.dart';
import 'package:homify/features/auth/presentation/providers/registration_flow_provider.dart';
import 'package:homify/features/home/presentation/pages/account_page.dart';
import 'package:homify/features/home/presentation/pages/home_page.dart';
import 'package:homify/features/properties/presentation/pages/add_property_page.dart';
import 'package:homify/features/properties/presentation/pages/property_success_page.dart';
import 'package:homify/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:homify/features/auth/presentation/providers/user_role_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.matchedLocation;
      debugPrint('--- ROUTER RUN ---');
      debugPrint('PATH: $path');

      // --- PRIORITY 1: IS THE USER IN THE "AIRLOCK"? ---
      // (Unchanged)
      final justRegistered = ref.watch(justRegisteredProvider);
      debugPrint('PRIORITY 1: justRegistered = $justRegistered');
      if (justRegistered) {
        final justRegisteredAs = ref.read(justRegisteredAsProvider);
        final successPath = justRegisteredAs == AccountType.owner
            ? '/owner-success'
            : '/tenant-success';
        if (path == successPath) {
          debugPrint('DECISION 1: Staying on success page');
          return null;
        }
        debugPrint('DECISION 1: Forcing to success page $successPath');
        return successPath;
      }

      // --- PRIORITY 2: IS AUTH LOADING? ---
      // (Unchanged)
      final authInit = ref.watch(authStateProvider);
      debugPrint('PRIORITY 2: authInit.isLoading = ${authInit.isLoading}');
      if (authInit.isLoading) {
        debugPrint('DECISION 2: Going to /loading');
        return '/loading';
      }

      // --- PRIORITY 3: DO WE HAVE A "SAVED INTENT"? ---
      // (This is the NEW, corrected logic)
      // Auth is loaded. We are not in the airlock.
      // Check if we just finished a flow (like the success page button).
      final postLoginRedirect = ref.read(postLoginRedirectProvider);
      debugPrint('PRIORITY 3: postLoginRedirect = $postLoginRedirect');

      if (postLoginRedirect != null) {
        debugPrint('DECISION 3: Restoring path to $postLoginRedirect');
        return postLoginRedirect; // Go to the saved path
      }

      // --- PRIORITY 4: GENERAL GUEST & LOGGED-IN RULES ---
      // (This logic is unchanged, but we stop "path == /loading")
      debugPrint('PRIORITY 4: path == /loading = ${path == '/loading'}');
      if (path == '/loading') {
        // If we were loading but had NO intent, just go home.
        debugPrint('DECISION 4: Loading finished, no intent, going home');
        return '/home';
      }

      final authState = ref.read(authStateProvider);
      final role = ref.read(userRoleProvider);
      final isLoggedIn = authState.value != null;
      final isGuest = role == AppUserRole.guest;
      debugPrint('PRIORITY 4: isLoggedIn = $isLoggedIn, role = $role');

      final isAuthPage = ['/', '/login', '/register'].contains(path);
      final isSuccessPage = [
        '/tenant-success',
        '/owner-success',
      ].contains(path);

      // ** LOGGED-IN RULES **
      if (isLoggedIn) {
        if (isSuccessPage) {
          debugPrint(
            'DECISION 4 (LOGGED IN): On success page, redirecting to /home',
          );
          return '/home';
        }
        if (isAuthPage) {
          debugPrint(
            'DECISION 4 (LOGGED IN): On auth page, redirecting to /home',
          );
          return '/home';
        }
        debugPrint('DECISION 4 (LOGGED IN): Allowing navigation.');
        return null;
      }

      // ** GUEST RULES **
      if (isGuest) {
        if (isAuthPage || path == '/home') {
          debugPrint('DECISION 4 (GUEST): Allowing navigation to auth/home.');
          return null;
        }
        debugPrint('DECISION 4 (GUEST): Redirecting to /login');
        return '/login';
      }

      debugPrint('--- ROUTER END: No decision, returning null ---');
      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingPage(),
      ),
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
