import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/features/auth/presentation/providers/user_role_provider.dart';

// Import our new providers and widget
import 'package:homify/features/home/presentation/providers/navigation_provider.dart';
import 'package:homify/features/home/presentation/widgets/app_bottom_nav_bar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = ref.read(bottomNavIndexProvider) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final navModel = ref.watch(navigationLogicProvider);
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final screens = navModel.screens;

    // This check prevents an error if the user role changes
    // and the new list of screens is shorter than the old index.
    final bool isIndexSafe =
        selectedIndex != null && selectedIndex < screens.length;

    // Track previous index for determining slide direction
    ref.listen<int?>(bottomNavIndexProvider, (previous, next) {
      if (previous != null && next != null && previous != next) {
        setState(() {
          _previousIndex = previous;
        });
      }
    });

    return Scaffold(
      extendBody: true,
      // --- AppBar unchanged ---
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

      // --- UPDATED BODY with AnimatedSwitcher for direct transitions ---
      body: isIndexSafe
          ? AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (child, animation) {
                // Determine slide direction based on index comparison
                final bool slideFromRight = selectedIndex > _previousIndex;

                // Slide animation
                final offsetAnimation =
                    Tween<Offset>(
                      begin: slideFromRight
                          ? const Offset(1.0, 0.0) // Coming from right
                          : const Offset(-1.0, 0.0), // Coming from left
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOutCubic,
                      ),
                    );

                return SlideTransition(position: offsetAnimation, child: child);
              },
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              child: Container(
                key: ValueKey<int>(selectedIndex),
                child: screens[selectedIndex],
              ),
            )
          : const Center(child: CircularProgressIndicator()),

      // --- Bottom Navigation Bar ---
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}
