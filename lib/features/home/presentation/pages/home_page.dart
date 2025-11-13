import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/features/auth/presentation/providers/user_role_provider.dart';
import 'package:homify/features/home/presentation/pages/explore_screen.dart';
import 'package:homify/features/home/presentation/pages/favorites_screen.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    var items = const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
      BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
    ];
    var screens = [
      const Placeholder(),
      const ExploreScreen(),
      const FavoritesScreen(),
    ];

    return Scaffold(
      extendBody: true,

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
                backgroundColor: const Color(0xFFF9E5C5), // Icon's background
                foregroundColor: const Color(0xFF32190D),
                child: Icon(Icons.person),
              ),
            ),
            onPressed: () {
              final roleAsync = ref.watch(userRoleProvider);

              debugPrint(
                'HOME PAGE: Profile clicked. Current role: $roleAsync',
              );
              if (roleAsync == AppUserRole.guest) {
                debugPrint('HOME PAGE: Showing Login Required dialog');
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
                debugPrint('HOME PAGE: Navigating to /account');
                context.push('/account');
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: Container(
        // 1. This margin creates the "floating" effect
        margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),

        // 2. This Decoration styles the container
        decoration: BoxDecoration(
          color: const Color(
            0xFF32190D,
          ).withValues(alpha: 0.95), // Glossy effect
          borderRadius: BorderRadius.circular(25.0), // Your border radius
          boxShadow: [
            // A subtle shadow to lift it off the page
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        // 3. This clips the BottomNavigationBar to the container's shape
        clipBehavior: Clip.antiAlias,

        // 4. Finally, the BottomNavigationBar itself
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          items: items,
          type: BottomNavigationBarType.fixed,

          // --- Styling the BottomNavigationBar ---
          backgroundColor: Colors.transparent, // VERY IMPORTANT
          elevation: 0,
          unselectedItemColor: const Color(0xFFF9E5C5).withValues(alpha: 0.7),
          // This color is overridden by our `_buildActiveIcon` widget,
          // but it's good practice to set it.
          selectedItemColor: const Color(0xFFF9E5C5),

          // --- Hide labels ---
          showSelectedLabels: false,
          showUnselectedLabels: false,
        ),
      ),
    );
  }
}
