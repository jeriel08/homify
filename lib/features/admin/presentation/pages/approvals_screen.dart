import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/core/utils/toast_helper.dart';
import 'package:homify/features/admin/presentation/providers/pending_properties_provider.dart';
import 'package:homify/features/admin/presentation/providers/property_verification_provider.dart';
import 'package:homify/features/admin/presentation/widgets/filter_chips_row.dart';
import 'package:homify/features/admin/presentation/widgets/pending_property_card.dart';
import 'package:homify/features/admin/presentation/widgets/property_details_sheet.dart';
import 'package:homify/features/properties/data/models/property_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ApprovalsScreen extends ConsumerStatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  ConsumerState<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends ConsumerState<ApprovalsScreen> {
  PropertyType? selectedType;

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingPropertiesProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      body: Padding(
        padding: EdgeInsetsGeometry.only(top: topPadding),
        child: pendingAsync.when(
          loading: () => _buildSkeleton(),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (detailsList) {
            final filtered = selectedType == null
                ? detailsList
                : detailsList
                      .where((d) => d.property.type == selectedType)
                      .toList();

            return RefreshIndicator(
              onRefresh: () async => ref.refresh(pendingPropertiesProvider),
              child: CustomScrollView(
                slivers: [
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
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: PendingPropertyCard(
                              propertyWithUser: propertyWithUser,
                              onTap: () => _showDetails(
                                context,
                                propertyWithUser.property as PropertyModel,
                              ),
                            ),
                          );
                        }, childCount: filtered.length),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: Gap(100)), // Bottom padding
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.circleCheck, size: 80, color: Colors.grey.shade400),
          const Gap(16),
          Text(
            'All caught up!',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            selectedType == null
                ? 'No pending approvals'
                : 'No ${selectedType!.name} pending',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: CustomScrollView(
        slivers: [
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
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                childCount: 5, // Show 5 skeleton cards
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Gap(100)),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context, PropertyModel property) {
    final verify = ref.read(verifyPropertyProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PropertyDetailsSheet(
        property: property,
        onApprove: () async {
          final result = await verify(property.id, true);
          result.fold(
            (_) => ToastHelper.error(
              context,
              'Failed',
              subtitle: 'Could not approve property',
            ),
            (_) => ToastHelper.success(
              context,
              'Success!',
              subtitle: 'Property approved successfully',
            ),
          );
          // if (context.mounted) Navigator.of(context).pop();
        },
        onReject: (reason) async {
          final result = await verify(
            property.id,
            false,
            rejectionReason: reason,
          );
          result.fold(
            (_) => ToastHelper.error(
              context,
              'Failed',
              subtitle: 'Could not reject property',
            ),
            (_) => ToastHelper.warning(
              context,
              'Rejected',
              subtitle: 'Property has been rejected',
            ),
          );
          // if (context.mounted) Navigator.of(context).pop();
        },
      ),
    );
  }
}
