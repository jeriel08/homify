import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/entities/user_entity.dart'; // For AccountType enum
import 'package:homify/core/widgets/loading_screen.dart';
import 'package:homify/features/auth/presentation/pages/landing_page.dart';
import 'package:homify/features/auth/presentation/pages/login_page.dart';
import 'package:homify/features/auth/presentation/pages/registration_page.dart';
import 'package:homify/features/auth/presentation/pages/role_selection_page.dart'; // Import this
import 'package:homify/features/auth/presentation/pages/success_pages/pending_email_verification.dart';
import 'package:homify/features/auth/presentation/pages/tenant_onboarding_page.dart'; // Import this
import 'package:homify/features/home/presentation/pages/account_page.dart';
import 'package:homify/features/home/presentation/pages/home_page.dart';
import 'package:homify/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:homify/features/auth/presentation/providers/current_user_provider.dart';
import 'package:homify/features/properties/presentation/pages/add_property_page.dart';
import 'package:homify/features/properties/presentation/pages/property_success_page.dart'; // Import new provider

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    // Refresh the router if Auth changes OR if Firestore User Data changes
    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(
        ref
            .watch(authStateProvider)
            .maybeWhen(
              data: (user) => Stream.value(user),
              orElse: () => Stream.value(null),
            ),
      ),
      GoRouterRefreshStream(
        ref
            .watch(currentUserProvider)
            .maybeWhen(
              data: (user) => Stream.value(user),
              orElse: () => Stream.value(null),
            ),
      ),
    ]),
    redirect: (context, state) {
      try {
        final path = state.matchedLocation;
        debugPrint('--- ROUTER REDIRECT CHECK: $path ---');

        // 1. Load Auth State
        final authState = ref.read(authStateProvider);
        if (authState.isLoading) return '/loading';

        final firebaseUser = authState.value;

        // 2. Guest Rules
        if (firebaseUser == null) {
          final isPublicPage = ['/', '/login', '/register'].contains(path);
          if (isPublicPage) return null;
          return '/login';
        }

        // 3. Load Firestore Data
        final userModelAsync = ref.read(currentUserProvider);
        if (userModelAsync.isLoading) {
          debugPrint('Router: Firestore Loading...');
          return '/loading';
        }
        final userModel = userModelAsync.value;

        final isAuthVerified = firebaseUser.emailVerified;
        final isFirestoreVerified = userModel?.emailVerified ?? false;

        // If EITHER says true, we consider them verified
        final isVerified = isAuthVerified || isFirestoreVerified;

        debugPrint(
          'Router: AuthVerified=$isAuthVerified, DBVerified=$isFirestoreVerified',
        );

        if (!isVerified) {
          if (path == '/verify-email') return null;
          return '/verify-email';
        }

        // 5. Onboarding Guard
        if (userModel != null && !userModel.onboardingComplete) {
          debugPrint(
            'Router: Onboarding Incomplete. Role: ${userModel.accountType}',
          );

          if (userModel.accountType == AccountType.tenant) {
            if (path == '/tenant-onboarding') return null;
            return '/tenant-onboarding';
          }

          // Owner Onboarding Check (Placeholder)
          if (userModel.accountType == AccountType.owner) {
            if (path == '/owner-onboarding') return null;
            return '/owner-onboarding';
          }
        }

        // 6. Completion Guard
        // If Onboarding is done, don't let them go back to setup pages
        if (userModel != null && userModel.onboardingComplete) {
          final restrictedPaths = [
            '/tenant-onboarding',
            '/role-selection',
            '/verify-email',
            '/owner-onboarding', // Lock owner out of onboarding url
          ];
          if (restrictedPaths.contains(path)) {
            return '/home';
          }
        }

        // 7. Default Home Redirect
        final isAuthPage = [
          '/',
          '/login',
          '/register',
          '/verify-email',
        ].contains(path);
        if (isAuthPage) return '/home';

        return null;
      } catch (e) {
        debugPrint('ROUTER CRASH: $e');
        return null;
      }
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

      // NEW ROUTES
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const PendingEmailVerificationPage(),
      ),
      GoRoute(
        path: '/role-selection',
        builder: (context, state) => const RoleSelectionPage(),
      ),
      GoRoute(
        path: '/tenant-onboarding',
        builder: (context, state) => const TenantOnboardingPage(),
      ),
      GoRoute(
        path: '/owner-onboarding',
        builder: (context, state) => const AddPropertyPage(),
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountPage(),
      ),
      GoRoute(
        path: '/property-success',
        builder: (context, state) => const PropertySuccessPage(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
