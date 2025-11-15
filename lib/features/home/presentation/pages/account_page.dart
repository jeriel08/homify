// lib/features/home/presentation/pages/account_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/features/auth/presentation/controllers/account_controller.dart';
import 'package:homify/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:homify/features/auth/presentation/providers/user_role_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    // This listener for the logout action is great. No changes needed.
    ref.listen<AsyncValue<void>>(logoutControllerProvider, (previous, next) {
      if (previous is AsyncLoading && next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (previous is AsyncLoading && next.hasValue) {
        context.go('/login');
      }
    });

    final logoutState = ref.watch(logoutControllerProvider);
    final isLoading = logoutState.isLoading;

    // Use the theme for consistent text styling
    final textTheme = Theme.of(context).textTheme;

    return userAsync.when(
      data: (user) {
        if (user == null) {
          // This redirect logic is good.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        String fullname = "${user.firstName} ${user.lastName}";

        ImageProvider? avatarBackgroundImage;
        Widget? avatarChild;

        if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
          // 1. User has a real photo
          avatarBackgroundImage = NetworkImage(user.photoUrl!);
          avatarChild = null;
        } else {
          // 2. User has NO photo, check gender for placeholder
          // (I am assuming the gender string is 'Male' or 'Female')
          if (user.gender == 'male') {
            avatarBackgroundImage = const AssetImage(
              'assets/images/placeholder_male.png',
            );
          } else if (user.gender == 'female') {
            avatarBackgroundImage = const AssetImage(
              'assets/images/placeholder_female.png',
            );
          } else {
            // 3. Gender is null or 'Other', use icon fallback
            avatarBackgroundImage = null; // No background image
            avatarChild = const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            );
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFFF8F0),
          appBar: AppBar(
            title: Text(
              'Profile & Settings',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // ───── 1. DYNAMIC PROFILE HEADER ─────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: avatarBackgroundImage,
                      child: avatarChild,
                    ),
                    const SizedBox(width: 16),

                    // --- Dynamic Name & Email ---
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // This now uses the user's actual name
                          Text(
                            fullname,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF32190D),
                            ),
                          ),
                          // This now shows the user's email
                          Text(
                            user.email, // <-- DYNAMIC
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ───── HOMIFY BANNER WITH CUSTOM IMAGE ─────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Custom House Image
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        // color: const Color(0xFFF9E5C5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Lottie.asset(
                          'assets/animations/GrowingHouse.json',
                          height: 40,
                          width: 40,
                          repeat: false,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Homify your place',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF32190D),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'It’s simple to get set up and start earning',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B4E31),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Divider(radius: BorderRadiusGeometry.circular(20)),

              // ───── 2. ACCOUNT SECTION ─────
              const _SectionHeader(title: 'Account Settings'),
              ListTile(
                leading: const Icon(LucideIcons.shield),
                title: const Text('Security & Password'),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () {
                  /* TODO: Navigate to password page */
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.bell),
                title: const Text('Notification Settings'),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () {
                  /* TODO: Navigate to notification settings */
                },
              ),
              ListTile(
                leading: const Icon(LucideIcons.circleQuestionMark),
                title: const Text('Help & Support'),
                trailing: const Icon(LucideIcons.chevronRight),
                onTap: () {
                  /* TODO: Navigate to help page */
                },
              ),

              // ───── 3. CONDITIONAL ADMIN SECTION ─────
              // This section will only appear if the user is an admin
              if (user.accountType == AppUserRole.admin) ...[
                const _SectionHeader(title: 'Admin Panel'),
                ListTile(
                  leading: const Icon(Icons.approval),
                  title: const Text('Review Pending Properties'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/pending-properties'),
                ),
                ListTile(
                  leading: const Icon(Icons.group_outlined),
                  title: const Text('Manage Users'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    /* TODO: Navigate to user management */
                  },
                ),
              ],

              const SizedBox(height: 12),

              Divider(radius: BorderRadiusGeometry.circular(20)),

              const SizedBox(height: 12),

              Padding(
                // Add padding to give the button some space
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700], // Danger color
                    foregroundColor: Colors.white, // Text and icon color
                    minimumSize: const Size(
                      double.infinity,
                      44,
                    ), // Full width, standard height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // Softer edges
                    ),
                  ),

                  // 1. We disable the button by setting onPressed to null if it's loading
                  onPressed: isLoading
                      ? null
                      : () async {
                          // 2. This is the exact same logic from your 'onTap'
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text(
                                'Are you sure you want to logout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => context.pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => context.pop(true),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );
                          if (confirm != true) return;
                          ref.read(logoutControllerProvider.notifier).logout();
                        },

                  // 3. The 'child' of the button changes based on the 'isLoading' state
                  child: isLoading
                      ? const SizedBox(
                          // Show progress indicator
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Color(0xFF32190D),
                          ),
                        )
                      : const Row(
                          // Show icon and text
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.logOut),
                            SizedBox(width: 10),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text('Error loading user: $err'))),
    );
  }
}

// A simple helper widget to create section headers
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.brown.shade600,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
