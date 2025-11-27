import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/features/home/presentation/providers/search_provider.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/presentation/widgets/tenant/tenant_property_card.dart';
import 'package:homify/features/properties/presentation/widgets/tenant/tenant_property_details_sheet.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SearchPropertyPage extends ConsumerStatefulWidget {
  const SearchPropertyPage({super.key});

  @override
  ConsumerState<SearchPropertyPage> createState() => _SearchPropertyPageState();
}

class _SearchPropertyPageState extends ConsumerState<SearchPropertyPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = [
    'House',
    'Apartment',
    'Condo',
    'Villa',
    'Price',
    'Bedrooms',
    'Amenities',
  ];
  String? _selectedFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    PropertyType? type;
    if (_selectedFilter != null) {
      // Simple mapping for demo purposes. Ideally, use a map or extension.
      try {
        type = PropertyType.values.firstWhere(
          (e) => e.name.toLowerCase() == _selectedFilter!.toLowerCase(),
        );
      } catch (_) {
        // If filter doesn't match a property type (e.g. Price), ignore type filter for now
        // or handle specific logic for other filters.
      }
    }
    ref.read(searchProvider.notifier).search(query: query, type: type);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final searchNotifier = ref.read(searchProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            searchNotifier.clearResults();
            Navigator.pop(context);
          },
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (value) {
            _performSearch(value);
          },
          onSubmitted: (value) {
            searchNotifier.addRecentSearch(value);
            _performSearch(value);
          },
          decoration: InputDecoration(
            hintText: 'Search for a property...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : null,
          ),
          style: const TextStyle(color: AppColors.primary, fontSize: 16),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(10),
          // Filter Chips Carousel
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF32190D),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = selected ? filter : null;
                      });
                      _performSearch(_searchController.text);
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: const Color(0xFFF9E5C5),
                    showCheckmark: false,
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF32190D)
                          : Colors.transparent,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Gap(24),

          // Content
          Expanded(child: _buildContent(searchState, searchNotifier)),
        ],
      ),
    );
  }

  Widget _buildContent(SearchState state, SearchNotifier notifier) {
    if (state.isLoading) {
      return Skeletonizer(
        enabled: true,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          },
        ),
      );
    }

    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    // Show Recent Searches if query is empty and no results (or explicitly check query)
    if (_searchController.text.isEmpty && state.results.isEmpty) {
      if (state.recentSearches.isEmpty) {
        return const Center(child: Text('Start searching...'));
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Recent Searches',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const Gap(10),
          Expanded(
            child: ListView.builder(
              itemCount: state.recentSearches.length,
              itemBuilder: (context, index) {
                final recent = state.recentSearches[index];
                return ListTile(
                  leading: const Icon(
                    LucideIcons.clock,
                    size: 20,
                    color: Colors.grey,
                  ),
                  title: Text(recent),
                  onTap: () {
                    _searchController.text = recent;
                    _performSearch(recent);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                    onPressed: () {
                      notifier.removeRecentSearch(recent);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    if (state.results.isEmpty) {
      return const Center(child: Text('No properties found.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Results',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const Gap(16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: state.results.length,
            itemBuilder: (context, index) {
              final property = state.results[index];
              return TenantPropertyCard(
                property: property,
                isFavorite: false,
                onFavorite: () {},
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        TenantPropertyDetailsSheet(property: property),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
