import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/admin/domain/entities/property_with_user.dart';
import 'package:homify/features/admin/presentation/providers/admin_provider.dart';
import 'package:homify/features/admin/presentation/widgets/admin_property_card.dart';
import 'package:homify/features/admin/presentation/widgets/admin_search_bar.dart';
import 'package:homify/features/admin/presentation/widgets/filter_chips_row.dart';
import 'package:homify/features/admin/presentation/widgets/property_details_sheet.dart';

import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AllPropertiesScreen extends ConsumerStatefulWidget {
  const AllPropertiesScreen({super.key});

  @override
  ConsumerState<AllPropertiesScreen> createState() =>
      _AllPropertiesScreenState();
}

class _AllPropertiesScreenState extends ConsumerState<AllPropertiesScreen> {
  PropertyType? selectedType;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(allPropertiesProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(
        title: Text(
          'All Properties',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFFFEDD4),
        foregroundColor: const Color(0xFF32190D),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: 0.2),
      ),
      body: propertiesAsync.when(
        loading: () => _buildSkeleton(topPadding),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (properties) {
          final filtered = properties.where((p) {
            final matchesType =
                selectedType == null || p.property.type == selectedType;
            final matchesSearch =
                _searchQuery.isEmpty ||
                p.property.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                p.user.fullName.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
            return matchesType && matchesSearch;
          }).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(allPropertiesProvider),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: const Gap(16)),
                // Search Bar
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: AdminSearchBar(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      hintText: 'Search properties or owners...',
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: const Gap(16)),
                SliverToBoxAdapter(
                  child: FilterChipsRow(
                    selectedType: selectedType,
                    onSelected: (type) => setState(() => selectedType = type),
                  ),
                ),
                const SliverToBoxAdapter(child: Gap(24)),
                if (filtered.isEmpty) ...[
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  ),
                ] else ...[
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final propertyWithUser = filtered[index];
                        return AdminPropertyCard(
                          propertyWithUser: propertyWithUser,
                          onTap: () => _showDetails(context, propertyWithUser),
                        );
                      }, childCount: filtered.length),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: Gap(100)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.house, size: 80, color: Colors.grey.shade400),
          const Gap(16),
          Text(
            'No properties found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            _searchQuery.isNotEmpty
                ? 'No results for "$_searchQuery"'
                : selectedType == null
                ? 'There are no properties yet'
                : 'No ${selectedType!.name} properties found',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(double topPadding) {
    return Skeletonizer(
      enabled: true,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: const Gap(16)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: const Gap(16)),
          SliverToBoxAdapter(
            child: FilterChipsRow(
              selectedType: selectedType,
              onSelected: (type) => setState(() => selectedType = type),
            ),
          ),
          const SliverToBoxAdapter(child: Gap(24)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                );
              }, childCount: 5),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, PropertyWithUser propertyWithUser) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PropertyDetailsSheet(
        property: propertyWithUser.property,
        // Hide actions if property is already approved (verified)
        showActions: !propertyWithUser.property.isVerified,
        onApprove: () {},
        onReject: (reason) {},
      ),
    );
  }
}
