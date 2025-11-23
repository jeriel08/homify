import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/messages/domain/entities/conversation_entity.dart';
import 'package:homify/features/messages/domain/entities/message_entity.dart';

abstract class MessageRepository {
  /// Stream of all conversations for the current user
  Stream<List<ConversationEntity>> getConversationsStream(String userId);

  /// Stream of messages for a specific chat
  Stream<List<MessageEntity>> getMessagesStream(String conversationId);

  /// Send a text message
  Future<Either<Failure, void>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  });

  /// Creates a new conversation or returns the existing ID if one exists.
  /// We use a unique ID strategy: "userA_userB" (sorted alphabetically)
  Future<Either<Failure, String>> startConversation({
    required String currentUserId,
    required String otherUserId,
  });

  /// Marks messages in a conversation as read for the current user
  Future<Either<Failure, void>> markAsRead(
    String conversationId,
    String userId,
  );
}
