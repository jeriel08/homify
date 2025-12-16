import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/features/profile/domain/entities/user_profile_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile profile;
  final bool showEditButton;
  final VoidCallback? onEditTap;
  final VoidCallback? onPhotoTap;
  final bool isUploadingPhoto;

  const ProfileHeader({
    super.key,
    required this.profile,
    this.showEditButton = false,
    this.onEditTap,
    this.onPhotoTap,
    this.isUploadingPhoto = false,
  });

  // Brand colors
  static const Color primary = Color(0xFF32190D);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);

  Color _getRoleColor(AccountType role) {
    switch (role) {
      case AccountType.admin:
        return Colors.red.shade700;
      case AccountType.owner:
        return Colors.blue.shade700;
      case AccountType.tenant:
        return Colors.green.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar with photo or placeholder
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: surface.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primary.withValues(alpha: 0.2),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: profile.photoUrl!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: primary.withValues(alpha: 0.5),
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          profile.gender == 'female'
                              ? 'assets/images/placeholder_female.png'
                              : 'assets/images/placeholder_male.png',
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        ),
                      )
                    : Image.asset(
                        profile.gender == 'female'
                            ? 'assets/images/placeholder_female.png'
                            : 'assets/images/placeholder_male.png',
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
              ),
            ),
            // Camera overlay button (only for own profile)
            if (showEditButton)
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: isUploadingPhoto ? null : onPhotoTap,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: isUploadingPhoto
                        ? const Padding(
                            padding: EdgeInsets.all(6),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            LucideIcons.camera,
                            size: 16,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
          ],
        ),
        const Gap(16),

        // Name with edit button
        Center(
          child: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    profile.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                  ),
                ),
                if (showEditButton) ...[
                  const Gap(8),
                  IconButton(
                    icon: const Icon(LucideIcons.pencil, size: 20),
                    color: primary,
                    onPressed: onEditTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
          ),
        ),
        const Gap(8),

        // Role badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getRoleColor(profile.role).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getRoleColor(profile.role).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            profile.displayRole,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _getRoleColor(profile.role),
            ),
          ),
        ),

        // Banned badge
        if (profile.isBanned) ...[
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block, size: 16, color: Colors.red),
                const Gap(4),
                Text(
                  'Banned',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
