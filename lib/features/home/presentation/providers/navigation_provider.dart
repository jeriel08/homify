import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circular_bottom_navigation/tab_item.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:homify/features/auth/presentation/providers/user_role_provider.dart';
import 'package:homify/features/home/presentation/pages/explore_screen.dart';
import 'package:homify/features/home/presentation/pages/favorites_screen.dart';
import 'package:homify/features/home/presentation/pages/tenant_home_screen.dart';
import 'package:homify/features/properties/presentation/pages/my_properties_screen.dart';
import 'package:homify/features/messages/presentation/pages/messages_screen.dart';
import 'package:homify/features/admin/presentation/pages/admin_dashboard_screen.dart';
import 'package:homify/features/admin/presentation/pages/approvals_screen.dart';
import 'package:homify/features/admin/presentation/pages/reports_screen.dart';
import 'package:homify/features/home/presentation/pages/about_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// Define the colors for our nav bar (same as before)
const Color _navBarActiveColor = Color(0xFFE05725);
const Color _navBarActiveTextColor = Colors.white;

// A simple class to hold our two lists
class NavigationModel {
  final List<TabItem> tabs;
  final List<Widget> screens;

  NavigationModel({required this.tabs, required this.screens});
}

// -----------------------------------------------------------------
// 1. The Provider for the currently selected tab index
// -----------------------------------------------------------------
final bottomNavIndexProvider = StateProvider<int?>((ref) {
  return 0; // Default to the first tab
});

// -----------------------------------------------------------------
// 2. The main "brain" provider
// -----------------------------------------------------------------
final navigationLogicProvider = Provider<NavigationModel>((ref) {
  // Watch the user's role
  final role = ref.watch(userRoleProvider);

  // Based on the role, return a different NavigationModel
  switch (role) {
    // --- ADMIN ---
    case AppUserRole.admin:
      return NavigationModel(
        tabs: [
          _buildTab(LucideIcons.layoutDashboard, 'Dashboard'),
          _buildTab(LucideIcons.circleCheckBig, 'Approvals'),
          _buildTab(LucideIcons.flag, 'Reports'),
          _buildTab(LucideIcons.messageCircle, 'Messages'),
        ],
        screens: const [
          AdminDashboardScreen(),
          ApprovalsScreen(),
          ReportsScreen(),
          MessagesScreen(),
        ],
      );

    // --- OWNER ---
    case AppUserRole.owner:
      return NavigationModel(
        tabs: [
          _buildTab(LucideIcons.house, 'Home'),
          _buildTab(LucideIcons.mapPinHouse, 'Explore'),
          _buildTab(LucideIcons.landPlot, 'Properties'),
          _buildTab(LucideIcons.messageCircle, 'Messages'),
        ],
        screens: const [
          TenantHomeScreen(), // Re-using the "feed"
          ExploreScreen(),
          MyPropertiesScreen(),
          MessagesScreen(),
        ],
      );

    // --- TENANT ---
    case AppUserRole.tenant:
      return NavigationModel(
        tabs: [
          _buildTab(LucideIcons.house, 'Home'),
          _buildTab(LucideIcons.mapPinHouse, 'Explore'),
          _buildTab(LucideIcons.heart, 'Favorites'),
          _buildTab(LucideIcons.messageCircle, 'Messages'),
        ],
        screens: const [
          TenantHomeScreen(),
          ExploreScreen(),
          FavoritesScreen(),
          MessagesScreen(),
        ],
      );

    // --- GUEST ---
    case AppUserRole.guest:
      return NavigationModel(
        tabs: [
          _buildTab(LucideIcons.house, 'Home'),
          _buildTab(LucideIcons.mapPinHouse, 'Explore'),
          _buildTab(LucideIcons.info, 'About'),
        ],
        screens: const [TenantHomeScreen(), ExploreScreen(), AboutScreen()],
      );
  }
});

// Helper function to build a TabItem with our consistent style
TabItem _buildTab(IconData icon, String title) {
  return TabItem(
    IconData(
      icon.codePoint,
      fontFamily: icon.fontFamily,
      fontPackage: icon.fontPackage,
      matchTextDirection: false,
    ),
    title,
    _navBarActiveColor,
    labelStyle: TextStyle(
      color: _navBarActiveTextColor,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
  );
}
