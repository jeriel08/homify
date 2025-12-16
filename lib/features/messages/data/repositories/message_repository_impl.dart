import 'package:dartz/dartz.dart';
import 'package:homify/core/error/failure.dart';
import 'package:homify/features/messages/data/datasources/message_remote_data_source.dart';
import 'package:homify/features/messages/data/models/message_model.dart';
import 'package:homify/features/messages/domain/entities/conversation_entity.dart';
import 'package:homify/features/messages/domain/entities/message_entity.dart';
import 'package:homify/features/messages/domain/repositories/message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageRemoteDataSource remoteDataSource;

  MessageRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<ConversationEntity>> getConversationsStream(String userId) {
    // The DataSource returns Models, which are Entities (thanks to inheritance),
    // so we can return the stream directly.
    return remoteDataSource.getConversationsStream(userId);
  }

  @override
  Stream<List<MessageEntity>> getMessagesStream(String conversationId) {
    return remoteDataSource.getMessagesStream(conversationId);
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    try {
      final messageModel = MessageModel(
        id: '', // Firestore generates this inside the collection
        senderId: senderId,
        content: content,
        timestamp:
            DateTime.now(), // Placeholder, serverTimestamp used in dataSource
        isRead: false,
      );

      await remoteDataSource.sendMessage(conversationId, messageModel);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to send message'));
    }
  }

  @override
  Future<Either<Failure, void>> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String imagePath,
  }) async {
    try {
      await remoteDataSource.sendImageMessage(
        conversationId: conversationId,
        senderId: senderId,
        imagePath: imagePath,
      );
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to send image'));
    }
  }

  @override
  Future<Either<Failure, String>> startConversation({
    required String currentUserId,
    required String otherUserId,
  }) async {
    try {
      final id = await remoteDataSource.startConversation(
        currentUserId,
        otherUserId,
      );
      return Right(id);
    } catch (e) {
      return const Left(ServerFailure('Failed to start conversation'));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(
    String conversationId,
    String userId,
  ) async {
    try {
      await remoteDataSource.markAsRead(conversationId, userId);
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to mark messages as read'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleReaction({
    required String conversationId,
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    try {
      await remoteDataSource.toggleReaction(
        conversationId: conversationId,
        messageId: messageId,
        userId: userId,
        emoji: emoji,
      );
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to toggle reaction'));
    }
  }

  @override
  Future<Either<Failure, void>> setConversationTheme({
    required String conversationId,
    required String userId,
    required String themeName,
  }) async {
    try {
      await remoteDataSource.setConversationTheme(
        conversationId: conversationId,
        userId: userId,
        themeName: themeName,
      );
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Failed to set theme'));
    }
  }
}
