import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/auth/presentation/providers/user_provider.dart';
import 'package:homify/features/properties/domain/entities/review_entity.dart';
import 'package:homify/features/properties/presentation/providers/reviews_provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ReviewCard extends ConsumerWidget {
  final ReviewEntity review;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isAuthor = currentUser?.uid == review.userId;
    final hasReported =
        currentUser != null && review.reports.contains(currentUser.uid);

    // Watch the user provider to get the latest user details (name, avatar)
    final userAsync = ref.watch(userProvider(review.userId));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  userAsync.when(
                    data: (user) => CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.secondary,
                      backgroundImage:
                          (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                          ? CachedNetworkImageProvider(user.photoUrl!)
                          : const AssetImage(
                                  'assets/images/placeholder_male.png',
                                )
                                as ImageProvider,
                    ),
                    loading: () => const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.secondary,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (_, _) => const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.secondary,
                      backgroundImage: AssetImage(
                        'assets/images/placeholder_male.png',
                      ),
                    ),
                  ),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      userAsync.when(
                        data: (user) => Text(
                          user.fullName,
                          style: HomifyTypography.semibold(
                            HomifyTypography.body2,
                          ),
                        ),
                        loading: () => Container(
                          width: 100,
                          height: 16,
                          color: Colors.grey[300],
                        ),
                        error: (_, _) => Text(
                          'Unknown User',
                          style: HomifyTypography.semibold(
                            HomifyTypography.body2,
                          ),
                        ),
                      ),
                      const Gap(2),
                      Text(
                        DateFormat.yMMMd().format(review.createdAt),
                        style: HomifyTypography.label3.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isAuthor)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit?.call();
                    } else if (value == 'delete') {
                      onDelete?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(LucideIcons.pencil, size: 16),
                          Gap(8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                          Gap(8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                )
              else if (currentUser != null)
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  onSelected: (value) {
                    if (value == 'report') {
                      // Redirect to report screen
                      context.push(
                        '/report',
                        extra: {
                          'targetId': review.userId,
                          'targetType': 'user',
                        },
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'report',
                      enabled: !hasReported,
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.flag,
                            size: 16,
                            color: hasReported
                                ? AppColors.textSecondary
                                : Colors.red,
                          ),
                          const Gap(8),
                          Text(
                            hasReported ? 'Reported' : 'Report User',
                            style: TextStyle(
                              color: hasReported
                                  ? AppColors.textSecondary
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const Gap(12),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                size: 16,
                color: Colors.amber,
              );
            }),
          ),
          const Gap(8),
          Text(
            review.comment,
            style: HomifyTypography.body2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Gap(16),
          Row(
            children: [
              _LikeButton(
                icon: LucideIcons.thumbsUp,
                count: review.likes.length,
                isActive:
                    currentUser != null &&
                    review.likes.contains(currentUser.uid),
                onTap: () {
                  if (currentUser != null) {
                    ref
                        .read(reviewsControllerProvider.notifier)
                        .toggleLike(review.id);
                  }
                },
              ),
              const Gap(16),
              _LikeButton(
                icon: LucideIcons.thumbsDown,
                count: review.dislikes.length,
                isActive:
                    currentUser != null &&
                    review.dislikes.contains(currentUser.uid),
                onTap: () {
                  if (currentUser != null) {
                    ref
                        .read(reviewsControllerProvider.notifier)
                        .toggleDislike(review.id);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _LikeButton({
    required this.icon,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const Gap(6),
            Text(
              count.toString(),
              style: HomifyTypography.medium(
                HomifyTypography.label3.copyWith(
                  color: isActive ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
