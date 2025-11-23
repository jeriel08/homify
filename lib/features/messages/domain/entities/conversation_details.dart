import 'package:homify/features/messages/domain/entities/conversation_entity.dart';
import 'package:homify/core/entities/user_entity.dart';

class ConversationDetails {
  final ConversationEntity conversation;
  final UserEntity otherUser; // The person you are talking to

  const ConversationDetails({
    required this.conversation,
    required this.otherUser,
  });
}
