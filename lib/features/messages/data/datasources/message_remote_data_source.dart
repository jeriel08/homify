import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/features/messages/data/models/conversation_model.dart';
import 'package:homify/features/messages/data/models/message_model.dart';

abstract class MessageRemoteDataSource {
  Stream<List<ConversationModel>> getConversationsStream(String userId);
  Stream<List<MessageModel>> getMessagesStream(String conversationId);
  Future<void> sendMessage(String conversationId, MessageModel message);
  Future<String> startConversation(String currentUserId, String otherUserId);
  Future<void> markAsRead(String conversationId, String userId);
}

class MessageRemoteDataSourceImpl implements MessageRemoteDataSource {
  final FirebaseFirestore _firestore;

  MessageRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<ConversationModel>> getConversationsStream(String userId) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('last_message_time', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ConversationModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Stream<List<MessageModel>> getMessagesStream(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy(
          'timestamp',
          descending: true,
        ) // Newest at bottom (for UI reverse list)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList(),
        );
  }

  @override
  Future<void> sendMessage(String conversationId, MessageModel message) async {
    final conversationRef = _firestore
        .collection('conversations')
        .doc(conversationId);
    final messagesRef = conversationRef.collection('messages');

    // Run a transaction to ensure the message is added AND the conversation summary is updated simultaneously
    return _firestore.runTransaction((transaction) async {
      // 1. Add the new message
      transaction.set(messagesRef.doc(), message.toFirestore());

      // 2. Update the parent conversation document with last message details
      // We use FieldValue.increment to atomically update the unread count
      // Note: In a real app, you'd calculate whose unread count to increment based on who is NOT the sender.
      transaction.update(conversationRef, {
        'last_message': message.content,
        'last_message_time': FieldValue.serverTimestamp(),
        // We will handle unread counts more dynamically in the UI or Cloud Functions,
        // but for now, let's just update the text.
      });
    });
  }

  @override
  Future<String> startConversation(
    String currentUserId,
    String otherUserId,
  ) async {
    // Generate a consistent ID: sort UIDs to ensure "A_B" is same as "B_A"
    final ids = [currentUserId, otherUserId]..sort();
    final conversationId = ids.join('_');

    final docRef = _firestore.collection('conversations').doc(conversationId);
    final docSnapshot = await docRef.get();

    if (!docSnapshot.exists) {
      // Create new if doesn't exist
      await docRef.set({
        'participants': [currentUserId, otherUserId],
        'last_message': '',
        'last_message_time': FieldValue.serverTimestamp(),
        'unread_counts': {currentUserId: 0, otherUserId: 0},
      });
    }

    return conversationId;
  }

  @override
  Future<void> markAsRead(String conversationId, String userId) async {
    // Reset unread count for this user to 0
    await _firestore.collection('conversations').doc(conversationId).update({
      'unread_counts.$userId': 0,
    });
  }
}
