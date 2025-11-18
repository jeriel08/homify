import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:homify/core/entities/property_entity.dart'; // Or PropertyModel
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/messages/presentation/pages/chat_screen.dart';
import 'package:homify/features/messages/presentation/providers/message_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ContactOwnerButton extends ConsumerStatefulWidget {
  final String ownerUid;

  const ContactOwnerButton({super.key, required this.ownerUid});

  @override
  ConsumerState<ContactOwnerButton> createState() => _ContactOwnerButtonState();
}

class _ContactOwnerButtonState extends ConsumerState<ContactOwnerButton> {
  bool _isLoading = false;

  Future<void> _handleContactOwner() async {
    setState(() => _isLoading = true);

    try {
      // 1. Get Current User
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to send a message'),
          ),
        );
        return;
      }

      // Prevent talking to yourself
      if (currentUser.uid == widget.ownerUid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot message yourself')),
        );
        return;
      }

      // 2. Fetch Owner Details (We need their name for the Chat Header)
      // We reuse the AuthRepository we created earlier
      final ownerUser = await ref
          .read(authRepositoryProvider)
          .getUser(widget.ownerUid);

      // 3. Start/Get Conversation ID
      final messageRepo = ref.read(messageRepositoryProvider);
      final result = await messageRepo.startConversation(
        currentUserId: currentUser.uid,
        otherUserId: widget.ownerUid,
      );

      // 4. Navigate or Show Error
      result.fold(
        (failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        },
        (conversationId) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                conversationId: conversationId,
                otherUser: ownerUser,
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Your Brand Primary Color
    const primary = Color(0xFFE05725);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _handleContactOwner,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(LucideIcons.messageCircle),
        label: Text(
          _isLoading ? 'Connecting...' : 'Contact Owner',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
