import 'dart:io';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/core/presentation/widgets/confirmation_reason_sheet.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/profile/data/services/profile_photo_service.dart';
import 'package:homify/features/profile/domain/entities/user_profile_entity.dart';
import 'package:homify/features/profile/domain/usecases/ban_user.dart';
import 'package:homify/features/profile/presentation/providers/profile_provider.dart';
import 'package:homify/features/profile/presentation/widgets/profile_header.dart';
import 'package:homify/features/profile/presentation/widgets/profile_info_section.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Brand colors
  static const Color primary = Color(0xFF32190D);
  static const Color background = Color(0xFFFFFAF5);

  final _photoService = ProfilePhotoService();
  final _imagePicker = ImagePicker();
  bool _isUploadingPhoto = false;

  Future<void> _pickAndUploadPhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() => _isUploadingPhoto = true);

      await _photoService.uploadProfilePhoto(
        widget.userId,
        File(pickedFile.path),
      );

      // Refresh the profile stream
      ref.invalidate(userProfileStreamProvider(widget.userId));

      if (mounted) {
        DelightToastBar(
          position: DelightSnackbarPosition.top,
          snackbarDuration: const Duration(seconds: 3),
          autoDismiss: true,
          builder: (context) => const ToastCard(
            color: Colors.green,
            leading: Icon(Icons.check_circle, size: 28, color: Colors.white),
            title: Text(
              'Profile photo updated!',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ).show(context);
      }
    } catch (e) {
      if (mounted) {
        DelightToastBar(
          position: DelightSnackbarPosition.top,
          snackbarDuration: const Duration(seconds: 3),
          autoDismiss: true,
          builder: (context) => ToastCard(
            color: Colors.red,
            leading: const Icon(
              Icons.error_outline,
              size: 28,
              color: Colors.white,
            ),
            title: Text(
              'Failed to upload photo: ${e.toString().replaceAll('Exception: ', '')}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ).show(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileStreamProvider(widget.userId));
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUser = currentUserAsync.asData?.value;

    final isOwnProfile = currentUser?.uid == widget.userId;
    final isAdmin = currentUser?.accountType == AccountType.admin;

    return Scaffold(
      backgroundColor: background,
      body: profileAsync.when(
        loading: () => _buildSkeletonLoading(context),
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
                if (!isOwnProfile)
                  IconButton(
                    icon: const Icon(LucideIcons.flag, color: primary),
                    onPressed: () {
                      context.push(
                        '/report',
                        extra: {
                          'targetId': widget.userId,
                          'targetType': 'user',
                        },
                      );
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
                  ProfileHeader(
                    profile: profile,
                    showEditButton: isOwnProfile,
                    onEditTap: () =>
                        context.push('/profile/edit/name/${widget.userId}'),
                    onPhotoTap: _pickAndUploadPhoto,
                    isUploadingPhoto: _isUploadingPhoto,
                  ),
                  const Gap(32),

                  // Personal Information
                  ProfileInfoSection(
                    title: 'Personal Information',
                    showEditButton: isOwnProfile,
                    onEditTap: () => context.push(
                      '/profile/edit/personal-information/${widget.userId}',
                    ),
                    rows: [
                      InfoRow(
                        label: 'Email',
                        value: profile.email,
                        icon: LucideIcons.mail,
                      ),
                      if (profile.occupation != null)
                        InfoRow(
                          label: 'Occupation',
                          value: profile.displayOccupation,
                          icon: LucideIcons.briefcase,
                        ),
                      if (profile.mobile != null)
                        InfoRow(
                          label: 'Mobile Number',
                          value: profile.mobile!,
                          icon: LucideIcons.phone,
                        ),
                      if (profile.school != null)
                        InfoRow(
                          label: 'School',
                          value: profile.school!,
                          icon: LucideIcons.school,
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

                  // Preferences Section
                  if (profile.preferences != null) ...[
                    const Gap(24),
                    ProfileInfoSection(
                      title: 'Preferences',
                      showEditButton: isOwnProfile,
                      onEditTap: () => context.push(
                        '/profile/edit/preferences/${widget.userId}',
                      ),
                      rows: [
                        if (profile.preferences!['dealbreakers'] != null &&
                            (profile.preferences!['dealbreakers']
                                    as List<dynamic>)
                                .isNotEmpty)
                          InfoRow(
                            label: 'Dealbreakers',
                            value:
                                (profile.preferences!['dealbreakers']
                                        as List<dynamic>)
                                    .join(', '),
                            icon: LucideIcons.shieldAlert,
                          ),
                        if (profile.preferences!['min_budget'] != null &&
                            profile.preferences!['max_budget'] != null)
                          InfoRow(
                            label: 'Budget Range',
                            value:
                                '₱${NumberFormat('#,###').format(profile.preferences!['min_budget'])} - ₱${NumberFormat('#,###').format(profile.preferences!['max_budget'])}',
                            icon: LucideIcons.wallet,
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
                          if (profile.isBanned) {
                            // Unban confirmation (simple dialog)
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Unban User?'),
                                content: Text(
                                  'Are you sure you want to unban ${profile.fullName}? They will regain access to the platform.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _handleBanUnban(
                                        context,
                                        ref,
                                        widget.userId,
                                        profile.isBanned,
                                        currentUser!.uid,
                                        null,
                                      );
                                    },
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: const Text('Unban'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            // Ban confirmation (reason sheet)
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ConfirmationReasonSheet(
                                title: 'Ban User',
                                subtitle:
                                    'Why are you banning ${profile.fullName}? This action will sign them out immediately.',
                                reasons: const [
                                  'Violation of Terms of Service',
                                  'Inappropriate Behavior',
                                  'Spam / Fake Account',
                                  'Fraudulent Activity',
                                  'Other',
                                ],
                                confirmLabel: 'Ban User',
                                confirmIcon: LucideIcons.shieldAlert,
                                confirmColor: AppColors.error,
                                onConfirm: (reason) {
                                  Navigator.pop(context);
                                  _handleBanUnban(
                                    context,
                                    ref,
                                    widget.userId,
                                    profile.isBanned,
                                    currentUser!.uid,
                                    reason,
                                  );
                                },
                              ),
                            );
                          }
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
    String? reason,
  ) async {
    try {
      if (isBanned) {
        // Unban user
        final unbanUseCase = ref.read(unbanUserUseCaseProvider);
        final result = await unbanUseCase(userId);

        result.fold(
          (failure) {
            if (context.mounted) {
              DelightToastBar(
                position: DelightSnackbarPosition.top,
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
            }
          },
          (_) {
            // Refresh profile
            ref.invalidate(userProfileProvider(userId));

            if (context.mounted) {
              DelightToastBar(
                snackbarDuration: const Duration(seconds: 3),
                position: DelightSnackbarPosition.top,
                builder: (context) => const ToastCard(
                  color: Colors.green,
                  leading: Icon(Icons.check_circle, color: Colors.white),
                  title: Text(
                    'User unbanned successfully',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ).show(context);
            }
          },
        );
      } else {
        // Ban user
        if (reason == null) return;
        final banUseCase = ref.read(banUserUseCaseProvider);
        final result = await banUseCase(
          BanUserParams(userId: userId, bannedBy: adminId, reason: reason),
        );

        result.fold(
          (failure) {
            if (context.mounted) {
              DelightToastBar(
                position: DelightSnackbarPosition.top,
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
            }
          },
          (_) {
            // Refresh profile
            ref.invalidate(userProfileProvider(userId));

            if (context.mounted) {
              DelightToastBar(
                position: DelightSnackbarPosition.top,
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
            }
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
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

  Widget _buildSkeletonLoading(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: background,
            elevation: 0,
            pinned: false,
            floating: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: primary),
              onPressed: () {},
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header skeleton
                ProfileHeader(
                  profile: UserProfile(
                    uid: 'skeleton',
                    firstName: 'Loading',
                    lastName: 'User',
                    email: 'loading@example.com',
                    role: AccountType.tenant,
                    createdAt: DateTime.now(),
                  ),
                ),
                const Gap(32),

                // Personal Information skeleton
                ProfileInfoSection(
                  title: 'Personal Information',
                  rows: [
                    InfoRow(
                      label: 'Email',
                      value: 'loading@example.com',
                      icon: LucideIcons.mail,
                    ),
                    InfoRow(
                      label: 'Occupation',
                      value: 'Loading...',
                      icon: LucideIcons.briefcase,
                    ),
                    InfoRow(
                      label: 'Mobile Number',
                      value: '+63 XXX XXX XXXX',
                      icon: LucideIcons.phone,
                    ),
                    InfoRow(
                      label: 'Member Since',
                      value: 'January 1, 2024',
                      icon: LucideIcons.calendar,
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
