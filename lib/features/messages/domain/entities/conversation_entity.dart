class ConversationEntity {
  final String id;
  final List<String> participants; // [currentUserId, otherUserId]
  final String lastMessage;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCounts; // Key: UserID, Value: Count

  const ConversationEntity({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCounts,
  });
}
