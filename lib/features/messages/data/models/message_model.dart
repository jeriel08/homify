import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/features/messages/domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.senderId,
    required super.content,
    required super.timestamp,
    required super.isRead,
    super.imageUrl,
    super.reactions,
    super.messageType = 'text',
    super.propertyData,
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
      imageUrl: data['image_url'] as String?,
      reactions: (data['reactions'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String)),
      messageType: data['message_type'] as String? ?? 'text',
      propertyData: data['property_data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sender_id': senderId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(), // Use server time
      'is_read': isRead,
      if (imageUrl != null) 'image_url': imageUrl,
      if (reactions != null) 'reactions': reactions,
      'message_type': messageType,
      if (propertyData != null) 'property_data': propertyData,
    };
  }
}
