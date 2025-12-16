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
import 'package:homify/features/auth/presentation/providers/user_role_provider.dart';

class SearchPropertyPage extends ConsumerStatefulWidget {
  const SearchPropertyPage({super.key});

  @override
  ConsumerState<SearchPropertyPage> createState() => _SearchPropertyPageState();
}

class _SearchPropertyPageState extends ConsumerState<SearchPropertyPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Map PropertyType enum to user-friendly display names and icons
  final Map<PropertyType, ({String name, IconData icon})>
  _propertyTypeFilters = {
    PropertyType.bedspacer: (name: 'Bedspacer', icon: LucideIcons.bedSingle),
    PropertyType.room: (name: 'Room', icon: LucideIcons.doorOpen),
    PropertyType.house: (name: 'House', icon: LucideIcons.house),
    PropertyType.apartment: (name: 'Apartment', icon: LucideIcons.building),
    PropertyType.dormitory: (name: 'Dormitory', icon: LucideIcons.building2),
  };

  PropertyType? _selectedFilter;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    ref
        .read(searchProvider.notifier)
        .search(query: query, type: _selectedFilter);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final searchNotifier = ref.read(searchProvider.notifier);
    final userRole = ref.watch(userRoleProvider);
    final isGuest = userRole == AppUserRole.guest;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(16),
              // Enhanced Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSearchBar(searchNotifier),
              ),
              const Gap(16),
              // Filter Chips with Icons
              _buildFilterChips(),
              const Gap(16),
              // Content
              Expanded(
                child: _buildContent(searchState, searchNotifier, isGuest),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(SearchNotifier searchNotifier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            onPressed: () {
              searchNotifier.clearResults();
              Navigator.pop(context);
            },
            icon: const Icon(
              LucideIcons.arrowLeft,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          // Search Icon
          const Icon(LucideIcons.search, color: AppColors.accent, size: 20),
          const Gap(12),
          // Text Field
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              autofocus: true,
              onChanged: (value) {
                setState(() {});
                _performSearch(value);
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  searchNotifier.addRecentSearch(value);
                }
                _performSearch(value);
              },
              decoration: InputDecoration(
                hintText: 'Search for a property...',
                hintStyle: TextStyle(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
          ),
          // Clear Button with Animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _searchController.text.isNotEmpty
                ? IconButton(
                    key: const ValueKey('clear'),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.x,
                        color: AppColors.textSecondary,
                        size: 14,
                      ),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                      _performSearch('');
                    },
                  )
                : const SizedBox(width: 48, key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _propertyTypeFilters.entries.map((entry) {
          final propertyType = entry.key;
          final displayName = entry.value.name;
          final icon = entry.value.icon;
          final isSelected = _selectedFilter == propertyType;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: FilterChip(
                avatar: Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                label: Text(
                  displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? propertyType : null;
                  });
                  _performSearch(_searchController.text);
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.surface,
                showCheckmark: false,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent(
    SearchState state,
    SearchNotifier notifier,
    bool isGuest,
  ) {
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
      return _buildErrorState(state.error!);
    }

    // Show Recent Searches if query is empty and no results
    if (_searchController.text.isEmpty && state.results.isEmpty) {
      if (state.recentSearches.isEmpty) {
        return _buildEmptySearchState();
      }
      return _buildRecentSearches(state.recentSearches, notifier);
    }

    if (state.results.isEmpty) {
      return _buildNoResultsState();
    }

    return _buildResultsList(state.results, isGuest);
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.search,
              size: 48,
              color: AppColors.accent.withValues(alpha: 0.7),
            ),
          ),
          const Gap(24),
          Text(
            'Find Your Perfect Home',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Search by property name, location, or type to discover amazing places',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.searchX,
              size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ),
          const Gap(24),
          Text(
            'No Properties Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Try adjusting your search or filters to find what you\'re looking for',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const Gap(24),
          if (_selectedFilter != null)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFilter = null;
                });
                _performSearch(_searchController.text);
              },
              icon: const Icon(LucideIcons.x, size: 18),
              label: const Text('Clear Filter'),
              style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.circleAlert,
              size: 48,
              color: AppColors.error,
            ),
          ),
          const Gap(24),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Gap(8),
          Text(
            error,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(
    List<String> recentSearches,
    SearchNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.history,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const Gap(8),
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  for (final search in List.from(recentSearches)) {
                    notifier.removeRecentSearch(search);
                  }
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(fontSize: 13, color: AppColors.accent),
                ),
              ),
            ],
          ),
        ),
        const Gap(8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: recentSearches.length,
            itemBuilder: (context, index) {
              final recent = recentSearches[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      LucideIcons.clock,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  title: Text(
                    recent,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      LucideIcons.x,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => notifier.removeRecentSearch(recent),
                  ),
                  onTap: () {
                    _searchController.text = recent;
                    setState(() {});
                    _performSearch(recent);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResultsList(List<PropertyEntity> results, bool isGuest) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Results',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Gap(10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${results.length}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final property = results[index];
              return TenantPropertyCard(
                property: property,
                isFavorite: false,
                showFavorite: !isGuest,
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
