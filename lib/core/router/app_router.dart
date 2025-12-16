import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/entities/user_entity.dart'; // For AccountType enum
import 'package:homify/core/presentation/widgets/loading_screen.dart';
import 'package:homify/core/presentation/pages/not_found_page.dart';
import 'package:homify/features/auth/presentation/pages/landing_page.dart';
import 'package:homify/features/auth/presentation/pages/login_page.dart';
import 'package:homify/features/auth/presentation/pages/registration_page.dart';
import 'package:homify/features/auth/presentation/pages/role_selection_page.dart';
import 'package:homify/features/auth/presentation/pages/success_pages/pending_email_verification.dart';
import 'package:homify/features/auth/presentation/pages/success_pages/tenant_success_page.dart';
import 'package:homify/features/auth/presentation/pages/success_pages/user_banned_screen.dart';
import 'package:homify/features/auth/presentation/pages/tenant_onboarding_page.dart';
import 'package:homify/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:homify/features/auth/presentation/pages/change_password_page.dart';
import 'package:homify/features/home/presentation/pages/account_page.dart';
import 'package:homify/features/home/presentation/pages/home_page.dart';
import 'package:homify/features/home/presentation/pages/about_screen.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/properties/presentation/pages/add_property_page.dart';
import 'package:homify/features/properties/presentation/pages/property_success_page.dart';
import 'package:homify/features/admin/presentation/pages/approvals_screen.dart';
import 'package:homify/features/admin/presentation/pages/all_properties_screen.dart';
import 'package:homify/features/admin/presentation/pages/all_users_screen.dart';
import 'package:homify/features/admin/presentation/pages/banned_users_screen.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:homify/features/reports/presentation/pages/admin_reports_screen.dart';
import 'package:homify/features/reports/presentation/pages/report_details_screen.dart';
import 'package:homify/features/reports/presentation/pages/submit_report_screen.dart';
import 'package:homify/features/profile/presentation/pages/profile_screen.dart';
import 'package:homify/features/profile/presentation/pages/edit_pages/edit_name.dart';
import 'package:homify/features/profile/presentation/pages/edit_pages/edit_personal_information.dart';
import 'package:homify/features/profile/presentation/pages/edit_pages/edit_preferences.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: RouterRefreshNotifier(ref),
    errorBuilder: (context, state) => const NotFoundPage(),
    redirect: (context, state) {
      try {
        final path = state.matchedLocation;
        debugPrint('--- ROUTER REDIRECT CHECK: $path ---');

        // 1. Load Auth State
        final authState = ref.read(authStateProvider);
        debugPrint(
          'Router: AuthState isLoading=${authState.isLoading}, hasValue=${authState.hasValue}, value=${authState.value}',
        );

        if (authState.isLoading && !authState.hasValue) {
          debugPrint('Router: AuthState is initial loading -> /loading');
          return '/loading';
        }

        final firebaseUser = authState.value;

        // 2. Guest Rules
        if (firebaseUser == null) {
          debugPrint("Router: User logged out (firebaseUser is null)");
          final publicRoutes = [
            '/',
            '/login',
            '/register',
            '/home',
            '/forgot-password',
          ];
          final isAllowed = publicRoutes.any((route) => path.startsWith(route));

          if (isAllowed) {
            debugPrint('Router: Public route allowed -> null');
            return null;
          }

          debugPrint('Router: Redirecting to landing -> /');
          return '/';
        }

        // 3. Load Firestore Data
        final userModelAsync = ref.read(currentUserProvider);
        debugPrint(
          'Router: CurrentUser isLoading=${userModelAsync.isLoading}, hasValue=${userModelAsync.hasValue}',
        );

        if (userModelAsync.isLoading && !userModelAsync.hasValue) {
          debugPrint('Router: Firestore Initial Loading -> /loading');
          return '/loading';
        }

        final userModel = userModelAsync.value;
        debugPrint('Router: UserModel loaded: ${userModel?.accountType}');

        final isAuthVerified = firebaseUser.emailVerified;
        final isFirestoreVerified = userModel?.emailVerified ?? false;
        final isVerified = isAuthVerified || isFirestoreVerified;

        debugPrint(
          'Router: AuthVerified=$isAuthVerified, DBVerified=$isFirestoreVerified',
        );

        if (!isVerified) {
          if (path == '/verify-email') return null;
          return '/verify-email';
        }

        // 4. Banned User Check
        if (userModel?.isBanned == true) {
          if (path == '/user-banned') return null;
          return '/user-banned';
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

          // Owner Onboarding Check
          if (userModel.accountType == AccountType.owner) {
            if (path == '/owner-onboarding') return null;
            return '/owner-onboarding';
          }
        }

        // 6. Completion Guard
        // If Onboarding is done, don't let them go back to setup pages
        if (userModel != null && userModel.onboardingComplete) {
          // Fix: If we just finished onboarding, redirect to success
          if (path == '/tenant-onboarding') {
            return '/tenant-success';
          }

          final restrictedPaths = [
            '/role-selection',
            '/verify-email',
            '/owner-onboarding',
            '/user-banned',
          ];
          if (restrictedPaths.contains(path)) {
            return '/home';
          }
        }

        // 7. Admin Guard
        if (path.startsWith('/admin')) {
          if (userModel?.accountType != AccountType.admin) {
            debugPrint('Router: Non-admin attempted to access admin route');
            return '/home';
          }
        }

        // 8. Default Home Redirect
        final isAuthPage = [
          '/',
          '/login',
          '/register',
          '/verify-email',
          '/loading',
          '/forgot-password',
        ].contains(path);

        if (isAuthPage) {
          debugPrint('Router: Authenticated user on auth page -> /home');
          return '/home';
        }

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
      GoRoute(
        path: '/user-banned',
        builder: (context, state) => const UserBannedScreen(),
      ),

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
        path: '/tenant-success',
        builder: (context, state) => const TenantRegistrationSuccess(),
      ),
      GoRoute(
        path: '/owner-onboarding',
        builder: (context, state) => const AddPropertyPage(),
      ),
      GoRoute(
        path: '/add-property',
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
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(showAppBar: true),
      ),
      // ADMIN ROUTES
      GoRoute(
        path: '/admin/approvals',
        builder: (context, state) => const ApprovalsScreen(),
      ),
      GoRoute(
        path: '/admin/all-properties',
        builder: (context, state) => const AllPropertiesScreen(),
      ),
      GoRoute(
        path: '/admin/all-users',
        builder: (context, state) {
          final extra = state.extra as int? ?? 0;
          return AllUsersScreen(initialIndex: extra);
        },
      ),
      GoRoute(
        path: '/admin/banned-users',
        builder: (context, state) => const BannedUsersScreen(),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (context, state) => const AdminReportsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (context, state) {
              final report = state.extra as ReportEntity;
              return ReportDetailsScreen(report: report);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/report',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return SubmitReportScreen(
            targetId: extra['targetId'] as String?,
            targetType: extra['targetType'] as String,
          );
        },
      ),
      // PROFILE ROUTES - more specific routes first
      GoRoute(
        path: '/profile/edit/name/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return EditNamePage(userId: userId);
        },
      ),
      GoRoute(
        path: '/profile/edit/personal-information/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return EditPersonalInformationPage(userId: userId);
        },
      ),
      GoRoute(
        path: '/profile/edit/preferences/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return EditPreferencesPage(userId: userId);
        },
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
    ],
  );
});

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(Ref ref) {
    // Notify the router if Auth State changes
    ref.listen(authStateProvider, (_, _) => notifyListeners());
    // Notify the router if User Data (Firestore) changes
    ref.listen(currentUserProvider, (_, _) => notifyListeners());
  }
}
