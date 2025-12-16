import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/features/admin/presentation/providers/admin_provider.dart';
import 'package:homify/features/admin/presentation/widgets/admin_search_bar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BannedUsersScreen extends ConsumerStatefulWidget {
  const BannedUsersScreen({super.key});

  @override
  ConsumerState<BannedUsersScreen> createState() => _BannedUsersScreenState();
}

class _BannedUsersScreenState extends ConsumerState<BannedUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF5),
      appBar: AppBar(
        title: Text(
          'Banned Users',
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
      body: Column(
        children: [
          const Gap(16),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AdminSearchBar(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              hintText: 'Search banned users...',
            ),
          ),
          const Gap(16),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    final allUsersAsync = ref.watch(allUsersProvider);

    return allUsersAsync.when(
      data: (users) {
        final filteredUsers = users.where((user) {
          if (!user.isBanned) return false;

          if (_searchQuery.isEmpty) return true;

          final name = user.fullName.toLowerCase();
          final email = user.email.toLowerCase();
          return name.contains(_searchQuery) || email.contains(_searchQuery);
        }).toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.ban, size: 60, color: Colors.grey.shade400),
                const Gap(16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No banned users found'
                      : 'No results found',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: filteredUsers.length,
          separatorBuilder: (context, index) => const Gap(12),
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            final isMale = user.gender.toLowerCase() == 'male';
            final imageAsset = isMale
                ? 'assets/images/placeholder_male.png'
                : 'assets/images/placeholder_female.png';

            return InkWell(
              onTap: () {
                // Navigate to ProfileScreen
                context.push('/profile/${user.uid}');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      backgroundImage:
                          user.photoUrl != null && user.photoUrl!.isNotEmpty
                          ? CachedNetworkImageProvider(user.photoUrl!)
                          : AssetImage(imageAsset),
                    ),
                    const Gap(16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF32190D),
                            ),
                          ),
                          const Gap(4),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronRight,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
