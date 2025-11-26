import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/properties/presentation/providers/owner_dashboard_provider.dart';
import 'package:homify/features/properties/presentation/widgets/owner/owner_property_card.dart';
import 'package:homify/features/properties/presentation/widgets/owner/owner_property_details_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MyPropertiesScreen extends ConsumerWidget {
  const MyPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ownerDashboardProvider);

    return Scaffold(
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(ownerDashboardProvider.notifier).loadDashboard(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. KPI / Stats Cards
                    Row(
                      children: [
                        _buildStatCard(
                          'Properties',
                          state.properties.length.toString(),
                          LucideIcons.house,
                          Colors.blue,
                        ),
                        const Gap(16),
                        _buildStatCard(
                          'Favorites',
                          state.totalFavorites.toString(),
                          LucideIcons.heart,
                          Colors.red,
                        ),
                      ],
                    ),

                    const Gap(24),

                    const Text(
                      'Your Listings',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(16),

                    // 2. Property List
                    if (state.properties.isEmpty)
                      _buildEmptyState(context)
                    else
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.properties.length,
                        itemBuilder: (context, index) {
                          final property = state.properties[index];
                          return OwnerPropertyCard(
                            property: property,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => OwnerPropertyDetailsSheet(
                                  property: property,
                                  onEdit: () {
                                    // TODO: Navigate to edit screen
                                  },
                                  onDelete: () {
                                    // TODO: Show delete confirmation
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Add Property
        },
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Property'),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const Gap(16),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(LucideIcons.ghost, size: 64, color: Colors.grey[300]),
            const Gap(16),
            Text(
              'No properties yet',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
