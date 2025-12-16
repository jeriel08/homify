class MessageEntity {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final Map<String, String>? reactions; // key: userId, value: emoji
  final String? messageType; // 'text', 'image', 'property'
  final Map<String, dynamic>? propertyData; // For shared properties

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.imageUrl,
    this.reactions,
    this.messageType = 'text',
    this.propertyData,
  });
}
