import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/entities/user_entity.dart';
import 'package:homify/core/utils/toast_helper.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/messages/presentation/providers/message_provider.dart';
import 'package:homify/features/messages/presentation/providers/theme_provider.dart';
import 'package:homify/features/messages/presentation/widgets/chat_bubble.dart';
import 'package:homify/features/messages/presentation/widgets/theme_picker_dialog.dart';
import 'package:homify/features/messages/presentation/widgets/property_picker_sheet.dart';
import 'package:homify/features/profile/presentation/pages/profile_screen.dart';
import 'package:homify/features/properties/presentation/widgets/tenant/tenant_property_details_sheet.dart';
import 'package:homify/features/properties/properties_providers.dart';
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

    // 3. Watch per-conversation theme from Firestore
    final conversationAsync = ref.watch(conversationProvider(conversationId));
    final conversationData = conversationAsync.value;
    final themePrefs = conversationData?.themePreferences ?? {};
    final currentThemeName = themePrefs[currentUser?.uid];
    final theme = MessageThemeColor.values.firstWhere(
      (t) => t.name == currentThemeName,
      orElse: () => MessageThemeColor.defaultColor,
    );

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
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(userId: otherUser.uid),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child:
                      otherUser.photoUrl != null &&
                          otherUser.photoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: otherUser.photoUrl!,
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 36,
                            height: 36,
                            color: surface,
                            child: const Icon(
                              LucideIcons.user,
                              color: primary,
                              size: 20,
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            otherUser.gender == 'female'
                                ? 'assets/images/placeholder_female.png'
                                : 'assets/images/placeholder_male.png',
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          otherUser.gender == 'female'
                              ? 'assets/images/placeholder_female.png'
                              : 'assets/images/placeholder_male.png',
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                ),
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
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.phone, color: textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(LucideIcons.palette, color: theme.color),
            onPressed: () {
              if (currentUser == null) return;
              ThemePickerDialog.show(
                context,
                ref: ref,
                conversationId: conversationId,
                userId: currentUser.uid,
                currentTheme: theme,
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

                    // Use theme color for user's bubble only
                    final themeColor = isMe ? theme.color : null;

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
                      onPropertyTap: () async {
                        final propertyId = msg.propertyData?['id'] as String?;
                        if (propertyId == null) {
                          ToastHelper.warning(
                            context,
                            'Property data not available',
                          );
                          return;
                        }

                        // Fetch the full property
                        final result = await ref
                            .read(propertyRepositoryProvider)
                            .getPropertyById(propertyId);
                        result.fold(
                          (failure) => ToastHelper.error(
                            context,
                            'Could not load property',
                          ),
                          (property) {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => TenantPropertyDetailsSheet(
                                property: property,
                              ),
                            );
                          },
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
    // Watch per-conversation theme
    final currentUser = ref.watch(currentUserProvider).value;
    final conversationAsync = ref.watch(
      conversationProvider(widget.conversationId),
    );
    final themePrefs = conversationAsync.value?.themePreferences ?? {};
    final themeName = themePrefs[currentUser?.uid];
    final theme = MessageThemeColor.values.firstWhere(
      (t) => t.name == themeName,
      orElse: () => MessageThemeColor.defaultColor,
    );

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
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (ctx) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Drag handle
                        Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        // Title
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.paperclip,
                                color: ChatScreen.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Attach',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: ChatScreen.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        // Options
                        _AttachmentOption(
                          icon: LucideIcons.image,
                          iconColor: Colors.blue,
                          label: 'Photo',
                          subtitle: 'Send an image from gallery',
                          onTap: () {
                            Navigator.pop(ctx);
                            widget.onPickImage();
                          },
                        ),
                        _AttachmentOption(
                          icon: LucideIcons.house,
                          iconColor: ChatScreen.primary,
                          label: 'Property',
                          subtitle: 'Share a property listing',
                          onTap: () {
                            Navigator.pop(ctx);
                            final currentUser = ref
                                .read(currentUserProvider)
                                .value;
                            if (currentUser == null) return;

                            PropertyPickerSheet.show(
                              context,
                              onPropertySelected: (property) async {
                                // Send property message
                                await ref
                                    .read(messageRemoteDataSourceProvider)
                                    .sendPropertyMessage(
                                      conversationId: widget.conversationId,
                                      senderId: currentUser.uid,
                                      propertyData: {
                                        'id': property.id,
                                        'name': property.name,
                                        'rent_amount': property.rentAmount,
                                        'image_url': property.imageUrls,
                                      },
                                    );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
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

/// A styled attachment option for the modal sheet
class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Color(0xFF32190D),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        color: Colors.grey.shade400,
        size: 20,
      ),
    );
  }
}
