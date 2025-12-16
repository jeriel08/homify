import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/properties/domain/entities/review_entity.dart';
import 'package:homify/features/properties/presentation/providers/reviews_provider.dart';
import 'package:homify/features/properties/presentation/widgets/reviews/review_card.dart';
import 'package:homify/features/properties/presentation/widgets/reviews/review_input_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ReviewList extends ConsumerWidget {
  final String propertyId;
  final bool canWriteReview;

  const ReviewList({
    super.key,
    required this.propertyId,
    this.canWriteReview = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsProvider(propertyId));
    final currentUser = FirebaseAuth.instance.currentUser;

    return reviewsAsync.when(
      data: (reviews) {
        final userReview =
            currentUser != null &&
            reviews.any((r) => r.userId == currentUser.uid);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.messageSquare,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const Gap(8),
                    Text(
                      'Reviews (${reviews.length})',
                      style: HomifyTypography.semibold(
                        HomifyTypography.heading6.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (canWriteReview && !userReview)
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => ReviewInputSheet(
                          onSubmit: (rating, comment) {
                            ref
                                .read(reviewsControllerProvider.notifier)
                                .addReview(propertyId, rating, comment);
                          },
                        ),
                      );
                    },
                    child: Text(
                      'Write a Review',
                      style: HomifyTypography.medium(
                        HomifyTypography.label3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(16),
            if (reviews.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.messageSquare,
                        size: 40,
                        color: AppColors.textSecondary.withValues(alpha: 0.4),
                      ),
                      const Gap(12),
                      Text(
                        'No reviews yet',
                        style: HomifyTypography.medium(
                          HomifyTypography.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                separatorBuilder: (context, index) => const Gap(16),
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  return ReviewCard(
                    review: review,
                    onEdit: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => ReviewInputSheet(
                          initialRating: review.rating,
                          initialComment: review.comment,
                          onSubmit: (rating, comment) {
                            ref
                                .read(reviewsControllerProvider.notifier)
                                .editReview(review.id, rating, comment);
                          },
                        ),
                      );
                    },
                    onDelete: () {
                      ref
                          .read(reviewsControllerProvider.notifier)
                          .deleteReview(review.id);
                    },
                  );
                },
              ),
          ],
        );
      },
      loading: () => Skeletonizer(
        enabled: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      LucideIcons.messageSquare,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const Gap(8),
                    Text(
                      'Reviews (0)',
                      style: HomifyTypography.semibold(
                        HomifyTypography.heading6.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Gap(16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => const Gap(16),
              itemBuilder: (context, index) {
                return ReviewCard(
                  review: ReviewEntity(
                    id: 'skeleton_$index',
                    propertyId: 'skeleton',
                    userId: 'skeleton',
                    userName: 'Skeleton User',
                    rating: 5,
                    comment:
                        'This is a skeleton comment to simulate loading state. It should be long enough to look realistic.',
                    createdAt: DateTime.now(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
