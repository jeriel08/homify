import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:homify/features/home/presentation/providers/navigation_provider.dart';

import 'package:homify/features/home/presentation/providers/bottom_nav_provider.dart';
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
          // Replace the entire IconButton with this Widget
          Consumer(
            builder: (context, ref, child) {
              final userAsync = ref.watch(authStateProvider);

              return userAsync.when(
                data: (user) {
                  // Determine avatar image (same logic as AccountPage)
                  ImageProvider? backgroundImage;
                  if (user?.photoUrl != null && user!.photoUrl!.isNotEmpty) {
                    backgroundImage = NetworkImage(user.photoUrl!);
                  } else if (user?.gender == 'male') {
                    backgroundImage = const AssetImage(
                      'assets/images/placeholder_male.png',
                    );
                  } else if (user?.gender == 'female') {
                    backgroundImage = const AssetImage(
                      'assets/images/placeholder_female.png',
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Material(
                      color: const Color(0xFFF9E5C5),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          28,
                        ), // for ripple effect
                        onTap: () {
                          if (user == null || user.email.isEmpty) {
                            // Guest flow
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
                                      context.go('/login');
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
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF32190D),
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            image: backgroundImage != null
                                ? DecorationImage(
                                    image: backgroundImage,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: backgroundImage == null
                              ? const Icon(
                                  Icons.person,
                                  color: Color(0xFF32190D),
                                  size: 24,
                                )
                              : null,
                        ),
                      ),
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFF9E5C5),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (_, _) => const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFE05725),
                    child: Icon(Icons.error, color: Colors.white),
                  ),
                ),
              );
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

      // --- Bottom Navigation Bar (slides down when details are open on Explore) ---
      bottomNavigationBar: Consumer(
        builder: (context, ref, child) {
          final isVisible = ref.watch(bottomNavVisibilityProvider);

          return AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            offset: isVisible ? Offset.zero : const Offset(0, 1.0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: isVisible ? 1.0 : 0.0,
              child: const AppBottomNavBar(),
            ),
          );
        },
      ),
    );
  }
}
