import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/home/presentation/providers/navigation_provider.dart';

// 1. Change to a ConsumerStatefulWidget
class AppBottomNavBar extends ConsumerStatefulWidget {
  const AppBottomNavBar({super.key});

  // Define our theme colors
  static const Color navBarBgColor = Color(0xFF32190D);
  static const Color navBarInactiveColor = Color(0xFFF9E5C5);
  static const Color navBarActiveColor = Color(0xFFE05725);

  @override
  ConsumerState<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends ConsumerState<AppBottomNavBar> {
  // 2. Hold the controller in the widget's state
  late CircularBottomNavigationController _navigationController;

  @override
  void initState() {
    super.initState();
    // 3. Create the controller ONCE, using the provider's initial value
    final initialIndex = ref.read(bottomNavIndexProvider);
    _navigationController = CircularBottomNavigationController(initialIndex);
  }

  @override
  void dispose() {
    _navigationController.dispose(); // 4. Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get the list of tabs from our "brain" provider
    final navModel = ref.watch(navigationLogicProvider);
    final tabItems = navModel.tabs;

    // 2. Listen for provider changes and sync them to the controller
    ref.listen(bottomNavIndexProvider, (previous, next) {
      // If the provider's index changes, tell our stateful controller
      if (next != _navigationController.value) {
        // This syncs the controller if the state changes from elsewhere
        _navigationController.value = next;
      }
    });

    return SafeArea(
      top: false,
      bottom: false,
      left: true,
      right: true,
      child: CircularBottomNavigation(
        tabItems,
        // 3. Use the stable, stateful controller
        controller: _navigationController,

        // --- This is all our styling ---
        barBackgroundColor: AppBottomNavBar.navBarBgColor,

        // Added back the label color
        normalIconColor: AppBottomNavBar.navBarInactiveColor,

        backgroundBoxShadow: <BoxShadow>[
          BoxShadow(
            // 4. Fixed typo: .withValues() -> .withOpacity()
            color: AppBottomNavBar.navBarActiveColor.withValues(alpha: 0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],

        iconsSize: 24,

        // 5. This is the 'onTap' that updates our state
        selectedCallback: (int? index) {
          if (index == null) return;
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}
