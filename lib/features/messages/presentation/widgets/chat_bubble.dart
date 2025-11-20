import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;
  final String? imageUrl;
  final Map<String, String>? reactions;
  final VoidCallback? onLongPress;
  final String? myReaction;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.time,
    this.imageUrl,
    this.reactions,
    this.onLongPress,
    this.myReaction,
  });

  @override
  Widget build(BuildContext context) {
    // Colors from your other files
    // const Color primary = Color(0xFFE05725);
    const Color textPrimary = Color(0xFF32190D);
    const Color textSecondary = Color(0xFF6B4F3C);
    const Color myBubbleColor = Color(0xFFF9E5C5);
    const Color otherBubbleColor = Colors.white;

    // Prepare grouped reaction counts (e.g., 👍 2, ❤️ 1)
    final values = reactions?.values.toList() ?? const [];
    final Map<String, int> reactionCounts = {};
    for (final e in values) {
      reactionCounts[e] = (reactionCounts[e] ?? 0) + 1;
    }
    // Order: show user's reaction first if present
    final orderedEntries = reactionCounts.entries.toList()
      ..sort((a, b) {
        if (a.key == myReaction) return -1;
        if (b.key == myReaction) return 1;
        return 0;
      });

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 8),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isMe ? myBubbleColor : otherBubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
                boxShadow: [
                  if (!isMe)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (imageUrl != null && text.isNotEmpty) const Gap(8),
                  if (text.isNotEmpty)
                    Text(
                      text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  const Gap(6),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: textSecondary.withValues(alpha: 0.8),
                        ),
                  ),
                  if (orderedEntries.isNotEmpty) ...[
                    const Gap(6),
                    Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: orderedEntries.map((entry) {
                            final isMine = entry.key == myReaction;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  entry.key,
                                  style: TextStyle(
                                    fontSize: isMine ? 14 : 12,
                                    fontWeight:
                                        isMine ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                                if (entry.value > 1)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 2),
                                    child: Text(
                                      entry.value.toString(),
                                      style: TextStyle(
                                        fontSize: isMine ? 12 : 11,
                                        color: textSecondary.withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
  }
}
