import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/features/home/presentation/pages/search_property_page.dart';
import 'package:homify/features/home/presentation/providers/tenant_home_provider.dart';
import 'package:homify/features/home/presentation/widgets/property_carousel.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/presentation/widgets/tenant/tenant_property_card.dart';
import 'package:homify/features/properties/presentation/widgets/tenant/tenant_property_details_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TenantHomeScreen extends ConsumerStatefulWidget {
  const TenantHomeScreen({super.key});

  @override
  ConsumerState<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends ConsumerState<TenantHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tenantHomeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Skeletonizer(
        enabled: state.isLoading,
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: () => ref.read(tenantHomeProvider.notifier).loadData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                100,
              ), // Increased bottom padding for nav bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Search Bar with Container Transform
                  OpenContainer(
                    transitionType: ContainerTransitionType.fadeThrough,
                    openBuilder: (context, _) => const SearchPropertyPage(),
                    closedElevation: 0,
                    closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    closedColor: Colors.white,
                    closedBuilder: (context, openContainer) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.search,
                              color: AppColors.accent,
                            ),
                            const Gap(12),
                            Text(
                              'Search for a property...',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const Gap(24),

                  // 2. Near You Carousel
                  if (state.nearbyProperties.isNotEmpty || state.isLoading) ...[
                    _buildHeader(context, "Near You"),
                    const Gap(16),
                    PropertyCarousel(
                      properties: state.nearbyProperties,
                      onTap: _showPropertyDetails,
                    ),
                    const Gap(24),
                  ],

                  // 3. You Might Like Feed
                  if (state.recommendedProperties.isNotEmpty ||
                      state.isLoading) ...[
                    _buildHeader(context, "You might like"),
                    const Gap(16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.isLoading
                          ? 3
                          : state.recommendedProperties.length,
                      itemBuilder: (context, index) {
                        if (state.isLoading) {
                          if (state.recommendedProperties.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Skeleton.leaf(
                                child: Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                        final property = state.recommendedProperties[index];
                        return TenantPropertyCard(
                          property: property,
                          isFavorite:
                              false, // TODO: Hook up to riverpod provider
                          onFavorite: () {
                            // TODO: Toggle favorite logic
                          },
                          onTap: () => _showPropertyDetails(property),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  void _showPropertyDetails(PropertyEntity property) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TenantPropertyDetailsSheet(property: property),
    );
  }
}
