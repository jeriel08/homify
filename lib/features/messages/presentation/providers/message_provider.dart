import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/messages/data/datasources/message_remote_data_source.dart';
import 'package:homify/features/messages/data/repositories/message_repository_impl.dart';
import 'package:homify/features/messages/domain/entities/conversation_details.dart';
import 'package:homify/features/messages/domain/entities/message_entity.dart';
import 'package:homify/features/messages/domain/repositories/message_repository.dart';

// -----------------------------------------------------------------------------
// DEPENDENCY INJECTION (Repository & DataSource)
// -----------------------------------------------------------------------------

final messageRemoteDataSourceProvider = Provider<MessageRemoteDataSource>((
  ref,
) {
  return MessageRemoteDataSourceImpl(FirebaseFirestore.instance);
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepositoryImpl(
    remoteDataSource: ref.watch(messageRemoteDataSourceProvider),
  );
});

// -----------------------------------------------------------------------------
// STREAM PROVIDERS (The Live Data)
// -----------------------------------------------------------------------------

/// 1. Chat Messages Stream
/// Usage: ref.watch(chatStreamProvider('conversation_id'))
final chatStreamProvider = StreamProvider.family<List<MessageEntity>, String>((
  ref,
  conversationId,
) {
  final repository = ref.watch(messageRepositoryProvider);
  return repository.getMessagesStream(conversationId);
});

/// 2. Conversations List Stream (Combined with User Data)
/// Usage: ref.watch(conversationsProvider)
final conversationsProvider = StreamProvider<List<ConversationDetails>>((ref) {
  final user = ref
      .watch(currentUserProvider)
      .value; // Get current logged-in user

  if (user == null) return Stream.value([]); // Return empty if not logged in

  final messageRepo = ref.watch(messageRepositoryProvider);
  final authRepo = ref.watch(authRepositoryProvider);

  // A. Get the stream of raw conversations (IDs only)
  return messageRepo.getConversationsStream(user.uid).asyncMap((
    conversations,
  ) async {
    // Filter out empty conversations (no messages yet)
    final activeConversations = conversations.where(
      (c) => c.lastMessage.trim().isNotEmpty,
    );

    // B. Transform each conversation into 'ConversationDetails'
    final futures = activeConversations.map((conversation) async {
      // Find the participant ID that is NOT me
      final otherUserId = conversation.participants.firstWhere(
        (id) => id != user.uid,
        orElse: () => 'unknown',
      );

      // Fetch that user's profile
      // Note: We use 'try-catch' or handle failures silently here to prevent one
      // bad user ID from crashing the whole list.
      try {
        final otherUser = await authRepo.getUser(otherUserId);
        return ConversationDetails(
          conversation: conversation,
          otherUser: otherUser,
        );
      } catch (e) {
        // Fallback or handle deleted users
        return null;
      }
    });

    // C. Wait for all user fetches to finish and filter out nulls
    final results = await Future.wait(futures);
    return results.whereType<ConversationDetails>().toList();
  });
});

/// 3. Single Conversation Stream (for theme and other details)
/// Usage: ref.watch(conversationProvider('conversation_id'))
final conversationProvider = StreamProvider.family((
  ref,
  String conversationId,
) {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('conversations')
      .doc(conversationId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        final data = doc.data() as Map<String, dynamic>;
        return (
          id: doc.id,
          themePreferences: Map<String, String>.from(
            data['theme_preferences'] ?? {},
          ),
        );
      });
});
