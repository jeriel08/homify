import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/profile/domain/usecases/ban_user.dart';
import 'package:homify/features/profile/presentation/providers/profile_provider.dart';
import 'package:homify/features/profile/presentation/widgets/ban_user_dialog.dart';
import 'package:homify/features/profile/presentation/widgets/profile_header.dart';
import 'package:homify/features/profile/presentation/widgets/profile_info_section.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileScreen extends ConsumerWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  // Brand colors
  static const Color primary = Color(0xFF32190D);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color background = Color(0xFFFFFAF5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(userId));
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUser = currentUserAsync.asData?.value;

    final isOwnProfile = currentUser?.uid == userId;
    final isAdmin = currentUser?.accountType == AccountType.admin;

    return Scaffold(
      backgroundColor: background,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const Gap(16),
              Text(
                'Failed to load profile',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (profile) => CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: background,
              elevation: 0,
              pinned: false,
              floating: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: primary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                if (isOwnProfile)
                  IconButton(
                    icon: const Icon(LucideIcons.pencil, color: primary),
                    onPressed: () {
                      // Navigate to edit profile
                      Navigator.of(
                        context,
                      ).pushNamed('/profile/edit', arguments: profile);
                    },
                  ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header
                  ProfileHeader(profile: profile),
                  const Gap(32),

                  // Personal Information
                  ProfileInfoSection(
                    title: 'Personal Information',
                    rows: [
                      InfoRow(
                        label: 'Email',
                        value: profile.email,
                        icon: LucideIcons.mail,
                      ),
                      InfoRow(
                        label: 'Account Type',
                        value: profile.displayRole,
                        icon: LucideIcons.user,
                      ),
                      InfoRow(
                        label: 'Member Since',
                        value: DateFormat(
                          'MMMM d, y',
                        ).format(profile.createdAt),
                        icon: LucideIcons.calendar,
                      ),
                    ],
                  ),

                  // Ban Information (if banned)
                  if (profile.isBanned) ...[
                    const Gap(24),
                    ProfileInfoSection(
                      title: 'Ban Status',
                      rows: [
                        InfoRow(
                          label: 'Banned On',
                          value: profile.bannedAt != null
                              ? DateFormat(
                                  'MMMM d, y',
                                ).format(profile.bannedAt!)
                              : 'Unknown',
                          icon: LucideIcons.shieldAlert,
                        ),
                      ],
                    ),
                  ],

                  // Admin Actions
                  if (isAdmin && !isOwnProfile) ...[
                    const Gap(32),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => BanUserDialog(
                              userName: profile.fullName,
                              isBanned: profile.isBanned,
                              onConfirm: () {
                                _handleBanUnban(
                                  context,
                                  ref,
                                  userId,
                                  profile.isBanned,
                                  currentUser!.uid,
                                );
                              },
                            ),
                          );
                        },
                        icon: Icon(
                          profile.isBanned
                              ? LucideIcons.shieldCheck
                              : LucideIcons.shieldAlert,
                        ),
                        label: Text(
                          profile.isBanned ? 'Unban User' : 'Ban User',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: profile.isBanned
                              ? Colors.green
                              : Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBanUnban(
    BuildContext context,
    WidgetRef ref,
    String userId,
    bool isBanned,
    String adminId,
  ) async {
    try {
      if (isBanned) {
        // Unban user
        final unbanUseCase = ref.read(unbanUserUseCaseProvider);
        final result = await unbanUseCase(userId);

        result.fold(
          (failure) {
            DelightToastBar(
              snackbarDuration: const Duration(seconds: 3),
              builder: (context) => ToastCard(
                color: Colors.red,
                leading: const Icon(Icons.error_outline, color: Colors.white),
                title: Text(
                  'Failed to unban user: ${failure.message}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ).show(context);
          },
          (_) {
            // Refresh profile
            ref.invalidate(userProfileProvider(userId));

            DelightToastBar(
              snackbarDuration: const Duration(seconds: 3),
              builder: (context) => const ToastCard(
                color: Colors.green,
                leading: Icon(Icons.check_circle, color: Colors.white),
                title: Text(
                  'User unbanned successfully',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ).show(context);
          },
        );
      } else {
        // Ban user
        final banUseCase = ref.read(banUserUseCaseProvider);
        final result = await banUseCase(
          BanUserParams(userId: userId, bannedBy: adminId),
        );

        result.fold(
          (failure) {
            DelightToastBar(
              snackbarDuration: const Duration(seconds: 3),
              builder: (context) => ToastCard(
                color: Colors.red,
                leading: const Icon(Icons.error_outline, color: Colors.white),
                title: Text(
                  'Failed to ban user: ${failure.message}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ).show(context);
          },
          (_) {
            // Refresh profile
            ref.invalidate(userProfileProvider(userId));

            DelightToastBar(
              snackbarDuration: const Duration(seconds: 3),
              builder: (context) => const ToastCard(
                color: Colors.green,
                leading: Icon(Icons.check_circle, color: Colors.white),
                title: Text(
                  'User banned successfully',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ).show(context);
          },
        );
      }
    } catch (e) {
      DelightToastBar(
        snackbarDuration: const Duration(seconds: 3),
        builder: (context) => ToastCard(
          color: Colors.red,
          leading: const Icon(Icons.error_outline, color: Colors.white),
          title: Text(
            'An error occurred: $e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ).show(context);
    }
  }
}
