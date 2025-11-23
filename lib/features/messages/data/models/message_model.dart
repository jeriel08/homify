import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/features/messages/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.content,
    required super.timestamp,
    required super.isRead,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MessageModel(
      id: doc.id,
      senderId: data['sender_id'] ?? '',
      content: data['content'] ?? '',
      // Handle Firestore Timestamp conversion safely
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['is_read'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sender_id': senderId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(), // Use server time
      'is_read': isRead,
    };
  }
}
