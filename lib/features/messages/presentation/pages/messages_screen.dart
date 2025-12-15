import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/messages/presentation/pages/chat_screen.dart';
import 'package:homify/features/messages/presentation/providers/message_provider.dart';
import 'package:intl/intl.dart'; // You might need to add intl to pubspec.yaml
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color background = Color(0xFFFFFAF5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPadding = MediaQuery.of(context).padding.top;
    final conversationsAsync = ref.watch(conversationsProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: background,
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              backgroundColor: background,
              elevation: 0,
              pinned: true,
              centerTitle: false,
              title: Text(
                'Messages',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(LucideIcons.search, color: textPrimary),
                  onPressed: () {},
                ),
                const Gap(8),
              ],
            ),

            // Live List
            conversationsAsync.when(
              loading: () => SliverFillRemaining(
                child: Skeletonizer(
                  enabled: true,
                  child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) => _ConversationTile(
                      name: 'Loading User...',
                      lastMessage: 'Loading message content...',
                      time: '12:00 PM',
                      unreadCount: 0,
                      photoUrl: null,
                      gender: 'male',
                      onTap: () {},
                    ),
                  ),
                ),
              ),
              error: (err, stack) => SliverFillRemaining(
                child: Center(child: Text('Error loading chats: $err')),
              ),
              data: (detailsList) {
                if (detailsList.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text('No messages yet.')),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final details = detailsList[index];
                    final conversation = details.conversation;
                    final otherUser = details.otherUser;

                    // Calculate unread count for ME
                    final myUnreadCount =
                        conversation.unreadCounts[currentUser?.uid] ?? 0;

                    return _ConversationTile(
                      name: otherUser.fullName, // Using the getter we added
                      lastMessage: conversation.lastMessage,
                      // Simple formatting
                      time: _formatTime(conversation.lastMessageTime),
                      unreadCount: myUnreadCount,
                      photoUrl: otherUser.photoUrl,
                      gender: otherUser.gender,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              conversationId: conversation.id,
                              otherUser: otherUser,
                            ),
                          ),
                        );
                      },
                    );
                  }, childCount: detailsList.length),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays > 0) {
      return DateFormat('MMM d').format(time); // Requires intl package
    }
    return DateFormat('h:mm a').format(time);
  }
}

class _ConversationTile extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final String? photoUrl;
  final String gender;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.onTap,
    this.photoUrl,
    this.gender = 'male',
  });

  @override
  Widget build(BuildContext context) {
    final bool hasUnread = unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Profile Picture
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: MessagesScreen.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: photoUrl != null && photoUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: photoUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 56,
                          height: 56,
                          color: MessagesScreen.surface,
                          child: const Icon(
                            LucideIcons.user,
                            color: MessagesScreen.primary,
                            size: 28,
                          ),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          gender == 'female'
                              ? 'assets/images/placeholder_female.png'
                              : 'assets/images/placeholder_male.png',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        gender == 'female'
                            ? 'assets/images/placeholder_female.png'
                            : 'assets/images/placeholder_male.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const Gap(16),
            // Message Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                      color: MessagesScreen.textPrimary,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: hasUnread
                          ? MessagesScreen.textPrimary
                          : MessagesScreen.textSecondary,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Gap(12),
            // Timestamp and Unread Count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: hasUnread
                        ? MessagesScreen.primary
                        : MessagesScreen.textSecondary,
                    fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                const Gap(8),
                if (hasUnread)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: MessagesScreen.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount.toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
