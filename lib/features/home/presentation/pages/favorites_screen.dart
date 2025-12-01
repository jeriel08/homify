import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/features/home/presentation/providers/favorites_provider.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:homify/features/properties/presentation/widgets/tenant/tenant_property_details_sheet.dart';
import 'package:homify/features/properties/presentation/widgets/tenant/tenant_property_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesProvider);
    final favorites = favoritesState.values;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Favorites',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              Expanded(
                child: favorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.heart,
                              size: 48,
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                            const Gap(16),
                            Text(
                              'No Favorites Yet',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Gap(8),
                            Text(
                              'Start adding properties to your favorites',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: favorites.length,
                        itemBuilder: (itemContext, index) {
                          final property = favorites[index];
                          return TenantPropertyCard(
                            property: property,
                            isFavorite: true,
                            onFavorite: () {
                              ref
                                  .read(favoritesProvider.notifier)
                                  .toggle(property);

                              DelightToastBar(
                                builder: (toastContext) => ToastCard(
                                  color: Colors.white,
                                  leading: const Icon(
                                    LucideIcons.heartCrack,
                                    size: 28,
                                    color: Colors.grey,
                                  ),
                                  title: Text(
                                    'Removed from favorites',
                                    style: Theme.of(toastContext)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                position: DelightSnackbarPosition.top,
                                autoDismiss: true,
                                snackbarDuration: const Duration(seconds: 2),
                              ).show(context);
                            },
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) =>
                                    TenantPropertyDetailsSheet(
                                      property: property,
                                    ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
