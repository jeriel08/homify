import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/home/presentation/providers/tenant_home_provider.dart';
import 'package:homify/features/home/presentation/widgets/property_carousel.dart';
import 'package:homify/features/properties/presentation/widgets/tenant/tenant_property_card.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class TenantHomeScreen extends ConsumerStatefulWidget {
  const TenantHomeScreen({super.key});

  @override
  ConsumerState<TenantHomeScreen> createState() => _TenantHomeScreenState();
}

class _TenantHomeScreenState extends ConsumerState<TenantHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tenantHomeProvider);
    // Using the colors from your typography file or pending card
    const primaryColor = Color(0xFFE05725);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(tenantHomeProvider.notifier).loadData(),
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
                      // 1. Search Bar
                      Container(
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
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Where do you want to live?',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: const Icon(
                              LucideIcons.search,
                              color: primaryColor,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),

                      const Gap(24),

                      // 2. Near You Carousel
                      if (state.nearbyProperties.isNotEmpty) ...[
                        _buildHeader(context, "Near You"),
                        const Gap(16),
                        PropertyCarousel(properties: state.nearbyProperties),
                        const Gap(24),
                      ],

                      // 3. You Might Like Feed
                      _buildHeader(context, "You might like"),
                      const Gap(16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.recommendedProperties.length,
                        itemBuilder: (context, index) {
                          final property = state.recommendedProperties[index];
                          return TenantPropertyCard(
                            property: property,
                            isFavorite:
                                false, // TODO: Hook up to riverpod provider
                            onFavorite: () {
                              // TODO: Toggle favorite logic
                            },
                            onTap: () {
                              // TODO: Go to details page
                            },
                          );
                        },
                      ),
                    ],
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
        color: const Color(0xFF32190D),
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }
}
