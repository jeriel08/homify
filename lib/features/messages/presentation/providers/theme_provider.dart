import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/messages/domain/entities/conversation_entity.dart';

enum MessageThemeColor {
  defaultColor(
    Color(0xFFFCB242),
    Color(0xFFFEF3C7),
  ), // bubble: #FCB242, background: #F5EBE1
  red(Color(0xFFDC2626), Color(0xFFFEE2E2)),
  orange(Color(0xFFEA580C), Color(0xFFF7CFB2)),
  yellow(Color(0xFFEAB308), Color(0xFFFEF9E7)),
  green(Color(0xFF16A34A), Color(0xFFDCFCE7)),
  blue(Color(0xFF2563EB), Color(0xFFDEF2FF)),
  indigo(Color(0xFF4F46E5), Color(0xFFE0E7FF)),
  violet(Color(0xFF7C3AED), Color(0xFFF3E8FF));

  final Color bubbleColor;
  final Color backgroundColor;

  const MessageThemeColor(this.bubbleColor, this.backgroundColor);

  Color get color => bubbleColor;
}

/// Get the theme for a user from a conversation entity
MessageThemeColor getThemeFromConversation(
  ConversationEntity? conversation,
  String? userId,
) {
  if (conversation == null || userId == null) {
    return MessageThemeColor.defaultColor;
  }

  final themeName = conversation.themePreferences[userId];
  if (themeName == null) {
    return MessageThemeColor.defaultColor;
  }

  return MessageThemeColor.values.firstWhere(
    (t) => t.name == themeName,
    orElse: () => MessageThemeColor.defaultColor,
  );
}

// Keep the old provider for backwards compatibility (optional)
class MessageThemeNotifier extends Notifier<MessageThemeColor> {
  @override
  MessageThemeColor build() {
    return MessageThemeColor.defaultColor;
  }

  void setTheme(MessageThemeColor theme) {
    state = theme;
  }
}

final messageThemeProvider =
    NotifierProvider<MessageThemeNotifier, MessageThemeColor>(() {
      return MessageThemeNotifier();
    });
