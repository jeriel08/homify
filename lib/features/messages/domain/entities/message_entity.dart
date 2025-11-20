class MessageEntity {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final Map<String, String>? reactions; // key: userId, value: emoji

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.imageUrl,
    this.reactions,
  });
}
