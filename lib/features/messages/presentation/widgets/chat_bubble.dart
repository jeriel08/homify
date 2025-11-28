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
  final Color? bubbleColor;
  final String? messageType;
  final Map<String, dynamic>? propertyData;
  final VoidCallback? onPropertyTap;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.time,
    this.imageUrl,
    this.reactions,
    this.onLongPress,
    this.myReaction,
    this.bubbleColor,
    this.messageType = 'text',
    this.propertyData,
    this.onPropertyTap,
  });

  @override
  Widget build(BuildContext context) {
    // Colors from your other files
    // const Color primary = Color(0xFFE05725);
    const Color textPrimary = Color(0xFF32190D);
    const Color textSecondary = Color(0xFF6B4F3C);
    const Color defaultMyBubbleColor = Color(0xFFF9E5C5);
    const Color otherBubbleColor = Colors.white;

    final bubbleBackgroundColor =
        bubbleColor ?? (isMe ? defaultMyBubbleColor : otherBubbleColor);

    // Determine if text should be light or dark based on bubble color brightness
    final isLightBackground = _isLightColor(bubbleBackgroundColor);
    final textColor = isLightBackground ? textPrimary : Colors.white;
    final timeTextColor = isLightBackground
        ? textSecondary.withValues(alpha: 0.8)
        : Colors.white.withValues(alpha: 0.7);

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
            color: bubbleBackgroundColor,
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
              // Property Message Card
              if (messageType == 'property' && propertyData != null)
                _PropertyMessageWidget(
                  propertyData: propertyData!,
                  onTap: onPropertyTap,
                )
              else ...[
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(imageUrl!, fit: BoxFit.cover),
                  ),
                if (imageUrl != null && text.isNotEmpty) const Gap(8),
                if (text.isNotEmpty)
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
              const Gap(6),
              Text(
                time,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: timeTextColor),
              ),
              if (orderedEntries.isNotEmpty) ...[
                const Gap(6),
                Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
                                fontWeight: isMine
                                    ? FontWeight.w700
                                    : FontWeight.w500,
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

  // Helper method to determine if a color is light or dark
  bool _isLightColor(Color color) {
    // Calculate luminance
    final luminance =
        (0.299 * color.r + 0.587 * color.g + 0.114 * color.b) / 255;
    return luminance > 0.5;
  }
}

class _PropertyMessageWidget extends StatelessWidget {
  final Map<String, dynamic> propertyData;
  final VoidCallback? onTap;

  const _PropertyMessageWidget({required this.propertyData, this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = propertyData['name'] ?? 'Property';
    final rentAmount = propertyData['rent_amount'] ?? 0;
    final imageUrls = propertyData['image_urls'] ?? [];
    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first : null;

    const Color brand = Color(0xFFE05725);
    const Color textPrimary = Color(0xFF32190D);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            if (imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: const Color(0xFFF9E5C5),
                    child: const Center(
                      child: Icon(Icons.home, color: brand, size: 28),
                    ),
                  ),
                ),
              )
            else
              Container(
                height: 100,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9E5C5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.home, color: brand, size: 28),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₱ ${(rentAmount as num).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: brand,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
