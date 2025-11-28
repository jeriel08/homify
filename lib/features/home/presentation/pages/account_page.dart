// lib/features/home/presentation/pages/account_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/widgets/loading_screen.dart';
import 'package:homify/features/auth/presentation/controllers/account_controller.dart';
import 'package:homify/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/features/profile/presentation/providers/profile_provider.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authStateProvider);

    // Safe logout listener — only reacts when actually logging out
    ref.listen(logoutControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final logoutState = ref.watch(logoutControllerProvider);
    final isLoading = logoutState.isLoading;
    final textTheme = Theme.of(context).textTheme;

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: LoadingPage());
        }

        // Use stream provider for real-time name updates
        final profileAsync = ref.watch(userProfileStreamProvider(user.uid));
        final fullname = profileAsync.maybeWhen(
          data: (profile) => profile.fullName,
          orElse: () => "${user.firstName} ${user.lastName}",
        );

        ImageProvider? avatarBackgroundImage;
        Widget? avatarChild;

        if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
          avatarBackgroundImage = CachedNetworkImageProvider(user.photoUrl!);
          avatarChild = null;
        } else {
          if (user.gender == 'male') {
            avatarBackgroundImage = const AssetImage(
              'assets/images/placeholder_male.png',
            );
          } else if (user.gender == 'female') {
            avatarBackgroundImage = const AssetImage(
              'assets/images/placeholder_female.png',
            );
          } else {
            avatarBackgroundImage = null;
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
              // ───── PROFILE HEADER ─────
              Container(
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
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      context.push('/profile/${user.uid}');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: avatarBackgroundImage,
                            child: avatarChild,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullname,
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF32190D),
                                  ),
                                ),
                                Text(
                                  user.email,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            LucideIcons.chevronRight,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ───── HOMIFY BANNER (OWNERS ONLY) ─────
              if (user.accountType == AccountType.owner) ...[
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
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
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
                              'It\'s simple to get set up and start earning',
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
              ],

              // ───── SETTINGS SECTION ─────
              const _SectionHeader(title: 'Settings'),
              Container(
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
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: LucideIcons.bell,
                      title: 'Notification Settings',
                      onTap: () {
                        /* TODO: Navigate to notification settings */
                      },
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: LucideIcons.circleQuestionMark,
                      title: 'Help & Support',
                      onTap: () {
                        /* TODO: Navigate to help page */
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ───── ADMIN PANEL (ADMIN ONLY) ─────
              if (user.accountType == AccountType.admin) ...[
                const _SectionHeader(title: 'Admin Panel'),
                Container(
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
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.approval,
                        title: 'Review Pending Properties',
                        onTap: () => context.push('/pending-properties'),
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.group_outlined,
                        title: 'Manage Users',
                        onTap: () {
                          /* TODO: Navigate to user management */
                        },
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // ───── LOGOUT BUTTON ─────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          final router = GoRouter.of(context);
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

                          await ref
                              .read(logoutControllerProvider.notifier)
                              .logout();
                          router.go('/');
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Color(0xFF32190D),
                          ),
                        )
                      : const Row(
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

// Section header widget
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12, left: 4),
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

// Settings tile widget
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF32190D), size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF32190D),
                  ),
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                color: Colors.grey.shade400,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
