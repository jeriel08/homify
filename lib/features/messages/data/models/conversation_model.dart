import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/features/messages/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.participants,
    required super.lastMessage,
    required super.lastMessageTime,
    required super.unreadCounts,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ConversationModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['last_message'] ?? '',
      lastMessageTime:
          (data['last_message_time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // content: {'uid1': 2, 'uid2': 0}
      unreadCounts: Map<String, int>.from(data['unread_counts'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'last_message': lastMessage,
      'last_message_time': FieldValue.serverTimestamp(),
      'unread_counts': unreadCounts,
    };
  }
}
