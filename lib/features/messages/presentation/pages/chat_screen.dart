import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/core/utils/toast_helper.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/messages/presentation/providers/message_provider.dart';
import 'package:homify/features/messages/presentation/providers/theme_provider.dart';
import 'package:homify/features/messages/presentation/widgets/chat_bubble.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends ConsumerWidget {
  final String conversationId;
  final UserEntity otherUser;

  const ChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUser,
  });

  static const Color primary = Color(0xFFE05725);
  static const Color background = Color(0xFFFFFAF5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color surface = Color(0xFFF9E5C5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the specific stream for this conversation
    final messagesAsync = ref.watch(chatStreamProvider(conversationId));

    // 2. Get current user ID to know which bubbles are "mine"
    final currentUser = ref.watch(currentUserProvider).value;

    // 3. Watch theme color
    final theme = ref.watch(messageThemeProvider);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: surface,
              child: Icon(LucideIcons.user, color: primary, size: 20),
            ),
            const Gap(12),
            Expanded(
              child: Text(
                otherUser.fullName, // Dynamic Name
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.phone, color: textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(LucideIcons.palette, color: theme.color),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Message Theme'),
                  contentPadding: const EdgeInsets.all(12),
                  content: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: MessageThemeColor.values
                        .map(
                          (themeOption) => GestureDetector(
                            onTap: () {
                              ref
                                  .read(messageThemeProvider.notifier)
                                  .setTheme(themeOption);
                              Navigator.pop(ctx);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: themeOption.color,
                                    shape: BoxShape.circle,
                                    border: theme == themeOption
                                        ? Border.all(
                                            color: Colors.black,
                                            width: 3,
                                          )
                                        : null,
                                  ),
                                  child: theme == themeOption
                                      ? const Center(
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  themeOption.name,
                                  style: const TextStyle(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Chat List
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Say hello to ${otherUser.firstName}!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true, // Important for chat
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUser?.uid;

                    String? myReactionValue;
                    if (currentUser != null) {
                      myReactionValue = msg.reactions?[currentUser.uid];
                    }

                    // Watch theme color for user's bubble only
                    final themeColor = isMe
                        ? ref.watch(messageThemeProvider).color
                        : null;

                    return ChatBubble(
                      text: msg.content,
                      isMe: isMe,
                      time: DateFormat('h:mm a').format(msg.timestamp),
                      imageUrl: msg.imageUrl,
                      reactions: msg.reactions,
                      myReaction: myReactionValue,
                      bubbleColor: themeColor,
                      messageType: msg.messageType,
                      propertyData: msg.propertyData,
                      onPropertyTap: () {
                        // TODO: Navigate to property details
                        ToastHelper.info(
                          context,
                          'Property details coming soon',
                        );
                      },
                      onLongPress: () async {
                        if (currentUser == null) return;
                        final emoji = await showDialog<String>(
                          context: context,
                          barrierDismissible: true,
                          builder: (ctx) {
                            final options = [
                              '👍',
                              '❤️',
                              '😂',
                              '😮',
                              '😢',
                              '👏',
                            ];
                            return AlertDialog(
                              contentPadding: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              content: Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: options
                                    .map(
                                      (e) => InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () => Navigator.pop(ctx, e),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            e,
                                            style: const TextStyle(
                                              fontSize: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                          },
                        );
                        if (emoji != null) {
                          await ref
                              .read(messageRepositoryProvider)
                              .toggleReaction(
                                conversationId: conversationId,
                                messageId: msg.id,
                                userId: currentUser.uid,
                                emoji: emoji,
                              );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Input Area
          _ChatInput(
            conversationId: conversationId,
            onSend: (text) {
              if (currentUser == null) return;

              // Call Repository
              ref
                  .read(messageRepositoryProvider)
                  .sendMessage(
                    conversationId: conversationId,
                    senderId: currentUser.uid,
                    content: text,
                  );
            },
            onPickImage: () async {
              if (currentUser == null) return;
              final picker = ImagePicker();
              final picked = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85,
              );
              if (picked != null) {
                await ref
                    .read(messageRepositoryProvider)
                    .sendImageMessage(
                      conversationId: conversationId,
                      senderId: currentUser.uid,
                      imagePath: picked.path,
                    );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ChatInput extends ConsumerStatefulWidget {
  final Function(String) onSend;
  final VoidCallback onPickImage;
  final String conversationId;
  const _ChatInput({
    required this.onSend,
    required this.onPickImage,
    required this.conversationId,
  });

  @override
  ConsumerState<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<_ChatInput> {
  final _controller = TextEditingController();

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    widget.onSend(_controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(messageThemeProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 8,
        bottom: 8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.plus, color: ChatScreen.textPrimary),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Attach'),
                  contentPadding: const EdgeInsets.all(12),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.image),
                        title: const Text('Image'),
                        onTap: () {
                          Navigator.pop(ctx);
                          widget.onPickImage();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.home),
                        title: const Text('Send Property'),
                        onTap: () {
                          Navigator.pop(ctx);
                          // TODO: Show property picker
                          ToastHelper.info(
                            context,
                            'Property picker coming soon',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: ChatScreen.background,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: theme.color, width: 1.5),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.send, color: theme.color),
            onPressed: _handleSend,
          ),
        ],
      ),
    );
  }
}
