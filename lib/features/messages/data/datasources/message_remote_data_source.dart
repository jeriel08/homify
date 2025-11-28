import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/features/messages/data/models/conversation_model.dart';
import 'package:homify/features/messages/data/models/message_model.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

abstract class MessageRemoteDataSource {
  Stream<List<ConversationModel>> getConversationsStream(String userId);
  Stream<List<MessageModel>> getMessagesStream(String conversationId);
  Future<void> sendMessage(String conversationId, MessageModel message);
  Future<String> startConversation(String currentUserId, String otherUserId);
  Future<void> markAsRead(String conversationId, String userId);
  Future<void> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String imagePath,
  });
  Future<void> sendPropertyMessage({
    required String conversationId,
    required String senderId,
    required Map<String, dynamic> propertyData,
  });
  Future<void> toggleReaction({
    required String conversationId,
    required String messageId,
    required String userId,
    required String emoji,
  });
}

class MessageRemoteDataSourceImpl implements MessageRemoteDataSource {
  final FirebaseFirestore _firestore;
  final CloudinaryPublic _cloudinary;

  MessageRemoteDataSourceImpl(this._firestore)
      : _cloudinary = CloudinaryPublic('dcjhugzvs', 'homify_unsigned', cache: false);

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
      final last = (message.imageUrl != null && (message.content.isEmpty))
          ? '[Photo]'
          : message.content;
      transaction.update(conversationRef, {
        'last_message': last,
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

  @override
  Future<void> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String imagePath,
  }) async {
    // 1) Upload image to Cloudinary
    final uploadRes = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(
        imagePath,
        resourceType: CloudinaryResourceType.Image,
        folder: 'messages/$senderId',
      ),
    );

    // 2) Create a message with imageUrl and possibly empty content
    final message = MessageModel(
      id: '',
      senderId: senderId,
      content: '',
      timestamp: DateTime.now(),
      isRead: false,
      imageUrl: uploadRes.secureUrl,
      reactions: const {},
    );

    // 3) Store it like a normal message
    await sendMessage(conversationId, message);
  }

  @override
  Future<void> sendPropertyMessage({
    required String conversationId,
    required String senderId,
    required Map<String, dynamic> propertyData,
  }) async {
    // Create a special property message
    final message = MessageModel(
      id: '',
      senderId: senderId,
      content: 'Shared a property',
      timestamp: DateTime.now(),
      isRead: false,
      messageType: 'property',
      propertyData: propertyData,
      reactions: const {},
    );

    // Store it like a normal message
    await sendMessage(conversationId, message);
  }

  @override
  Future<void> toggleReaction({
    required String conversationId,
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    final msgRef = _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .doc(messageId);

    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(msgRef);
      final data = snap.data() ?? <String, dynamic>{};
      final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});

      if (reactions[userId] == emoji) {
        reactions.remove(userId); // remove same reaction (toggle off)
      } else {
        reactions[userId] = emoji; // set or change reaction
      }

      txn.update(msgRef, {'reactions': reactions});
    });
  }
}
