import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/features/auth/presentation/providers/user_role_provider.dart';

// Import our new providers and widget
import 'package:homify/features/home/presentation/providers/navigation_provider.dart';
import 'package:homify/features/home/presentation/widgets/app_bottom_nav_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get the list of screens and the current index from our new providers
    final navModel = ref.watch(navigationLogicProvider);
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    final screens = navModel.screens;

    // This check prevents an error if the user role changes
    // and the new list of screens is shorter than the old index.
    final bool isIndexSafe = selectedIndex! < screens.length;

    return Scaffold(
      extendBody: true, // This is good, it lets the body go behind the nav bar
      // --- This AppBar is unchanged, all its logic is still valid ---
      appBar: AppBar(
        title: Text(
          'Homify',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF32190D),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF9E5C5),
        foregroundColor: const Color(0xFF32190D),
        elevation: 6,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF32190D),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF9E5C5),
                foregroundColor: const Color(0xFF32190D),
                child: const Icon(Icons.person),
              ),
            ),
            onPressed: () {
              // --- This profile button logic is still perfect ---
              final roleAsync = ref.watch(userRoleProvider);

              if (roleAsync == AppUserRole.guest) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Login Required'),
                    content: const Text(
                      'Please log in to access your account.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.push('/login');
                        },
                        child: const Text('Log In'),
                      ),
                    ],
                  ),
                );
              } else {
                context.push('/account');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // --- 2. UPDATED BODY ---
      // The body now dynamically shows the correct screen based on the provider
      body: isIndexSafe
          ? screens[selectedIndex]
          : const Center(child: CircularProgressIndicator()),

      // --- 3. UPDATED BOTTOM NAVIGATION BAR ---
      // All that old, messy code is replaced with our one clean widget.
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}
