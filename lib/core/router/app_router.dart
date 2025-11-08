import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/features/auth/presentation/pages/landing_page.dart';
import 'package:homify/features/auth/presentation/pages/login_page.dart';
import 'package:homify/features/auth/presentation/pages/registration_page.dart';
import 'package:homify/features/auth/presentation/pages/owner_success_page.dart';
import 'package:homify/features/auth/presentation/pages/tenant_success_page.dart';
import 'package:homify/features/home/presentation/home.dart';

// 1. Create a provider for your router
final routerProvider = Provider<GoRouter>((ref) {
  // 2. Define your routes
  final routes = [
    // Initial route
    GoRoute(path: '/', builder: (context, state) => const LandingPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegistrationPage(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/tenant-success',
      builder: (context, state) => const TenantRegistrationSuccess(),
    ),
    GoRoute(
      path: '/owner-success',
      builder: (context, state) => const OwnerRegistrationSuccess(),
    ),
  ];

  // 3. Create the router
  return GoRouter(
    initialLocation: '/',
    routes: routes,
    // Optional: Add error handling
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
});
