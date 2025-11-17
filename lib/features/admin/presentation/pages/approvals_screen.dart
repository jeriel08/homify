import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/entities/property_entity.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:homify/features/admin/presentation/providers/pending_properties_provider.dart';
import 'package:homify/features/admin/presentation/widgets/pending_property_card.dart';
import 'package:homify/features/admin/presentation/widgets/property_details_sheet.dart';
import 'package:homify/features/properties/data/models/property_model.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ApprovalsScreen extends ConsumerStatefulWidget {
  const ApprovalsScreen({super.key});

  @override
  ConsumerState<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends ConsumerState<ApprovalsScreen> {
  PropertyType? selectedType; // null = All

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingPropertiesProvider);

    return pendingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (properties) {
        // Apply filter
        final filtered = selectedType == null
            ? properties
            : properties.where((p) => p.type == selectedType).toList();

        if (filtered.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async => ref.refresh(pendingPropertiesProvider),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            children: [
              // Filter Chips
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _filterChip(null, 'All'),
                  ...PropertyType.values.map(
                    (type) => _filterChip(type, _formatType(type)),
                  ),
                ],
              ),
              const Gap(24),

              // Property Cards
              ...filtered.map(
                (property) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: PendingPropertyCard(
                    property: property,
                    onTap: () => _showDetails(context, property),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip(PropertyType? type, String label) {
    final isSelected = selectedType == type;
    return FilterChip(
      label: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() => selectedType = isSelected ? null : type);
      },
      selectedColor: const Color(0xFFE05725),
      backgroundColor: Colors.grey.shade100,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF32190D),
        fontWeight: FontWeight.w600,
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    );
  }

  void _showDetails(BuildContext context, PropertyModel property) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PropertyDetailsSheet(
        property: property,
        onApprove: () => _approveProperty(property.id),
        onReject: () => _rejectProperty(property.id),
      ),
    );
  }

  Future<void> _approveProperty(String id) async {
    // TODO: Call use case to approve
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Property approved!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _rejectProperty(String id) async {
    // TODO: Call use case to reject
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Property rejected')));
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.circleCheck,
              size: 80,
              color: Colors.grey.shade400,
            ),
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
              style: HomifyTypography.body2.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatType(PropertyType type) {
    return type.name
        .replaceAll('_', ' ')
        .split(' ')
        .map((e) => '${e[0].toUpperCase()}${e.substring(1)}')
        .join(' ');
  }
}
