import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:homify/features/auth/presentation/providers/user_role_provider.dart';
import 'package:homify/features/home/presentation/pages/explore_screen.dart';
import 'package:homify/features/home/presentation/pages/favorites_screen.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedPos = 0;

  late final CircularBottomNavigationController _navigationController;

  final Color _navBarBgColor = const Color(0xFF32190D);
  final Color _navBarInactiveColor = const Color(0xFFF9E5C5);
  final Color _navBarActiveColor = const Color(0xFFE05725);
  final Color _navBarActiveTextColor = Colors.white;

  late final List<TabItem> _tabItems;

  final List<Widget> _screens = [
    const ExploreScreen(), // For "Home"
    const FavoritesScreen(), // For "Favorites"
    const Placeholder(
      child: Center(child: Text('Search Screen')),
    ), // For "Search"
    const Placeholder(
      child: Center(child: Text('Notifications Screen')),
    ), // For "Notifications"
  ];

  @override
  void initState() {
    super.initState();
    _navigationController = CircularBottomNavigationController(_selectedPos);

    _tabItems = [
      TabItem(
        Icons.home,
        "Home",
        _navBarActiveColor, // Active circle color
        labelStyle: TextStyle(
          color: _navBarActiveTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      // I added a "Favorites" tab since you have a FavoritesScreen
      TabItem(
        Icons.favorite,
        "Favorites",
        _navBarActiveColor, // Active circle color
        labelStyle: TextStyle(
          color: _navBarActiveTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      TabItem(
        Icons.search,
        "Search",
        _navBarActiveColor, // Active circle color
        labelStyle: TextStyle(
          color: _navBarActiveTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      TabItem(
        Icons.notifications,
        "Notifications",
        _navBarActiveColor, // Active circle color
        labelStyle: TextStyle(
          color: _navBarActiveTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _navigationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              // ADD THESE 5 LINES
              debugPrint('=== AUTH DEBUG START ===');
              final authValue = ref.read(authStateProvider).value;
              debugPrint(
                'Firebase UID: ${FirebaseAuth.instance.currentUser?.uid}',
              );
              debugPrint('authStateProvider.value: $authValue');
              debugPrint(
                'userRoleProvider (watch): ${ref.watch(userRoleProvider)}',
              );
              debugPrint('=== AUTH DEBUG END ===');

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
      body: _screens[_selectedPos],
      bottomNavigationBar: CircularBottomNavigation(
        _tabItems,
        controller: _navigationController,
        barBackgroundColor: _navBarBgColor,
        normalIconColor: _navBarInactiveColor,
      ),
    );
  }
}
