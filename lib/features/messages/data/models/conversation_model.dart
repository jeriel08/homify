import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homify/features/messages/domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.participants,
    required super.lastMessage,
    required super.lastMessageTime,
    required super.unreadCounts,
    super.themePreferences = const {},
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ConversationModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['last_message'] ?? '',
      lastMessageTime:
          (data['last_message_time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unreadCounts: Map<String, int>.from(data['unread_counts'] ?? {}),
      themePreferences: Map<String, String>.from(
        data['theme_preferences'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'last_message': lastMessage,
      'last_message_time': FieldValue.serverTimestamp(),
      'unread_counts': unreadCounts,
      'theme_preferences': themePreferences,
    };
  }
}
