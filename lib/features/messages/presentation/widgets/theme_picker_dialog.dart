import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:homify/features/messages/presentation/providers/message_provider.dart';
import 'package:homify/features/messages/presentation/providers/theme_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// A beautifully styled dialog for selecting a chat theme.
///
/// Follows the same design pattern as LogoutDialog for consistency.
class ThemePickerDialog extends ConsumerWidget {
  final String conversationId;
  final String userId;
  final MessageThemeColor currentTheme;

  const ThemePickerDialog({
    super.key,
    required this.conversationId,
    required this.userId,
    required this.currentTheme,
  });

  // Brand colors
  static const Color primary = Color(0xFFE05725);
  static const Color surface = Color(0xFFF9E5C5);
  static const Color textPrimary = Color(0xFF32190D);
  static const Color textSecondary = Color(0xFF6B4F3C);

  /// Shows the theme picker dialog.
  static Future<void> show(
    BuildContext context, {
    required WidgetRef ref,
    required String conversationId,
    required String userId,
    required MessageThemeColor currentTheme,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => ThemePickerDialog(
        conversationId: conversationId,
        userId: userId,
        currentTheme: currentTheme,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 340),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with background
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: currentTheme.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.palette,
                color: currentTheme.color,
                size: 32,
              ),
            ),

            const Gap(20),

            // Title
            const Text(
              'Choose Theme',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const Gap(8),

            // Message
            Text(
              'Personalize this conversation with a color theme',
              style: TextStyle(fontSize: 14, color: textSecondary, height: 1.4),
              textAlign: TextAlign.center,
            ),

            const Gap(24),

            // Theme Color Grid
            _buildThemeGrid(context, ref),

            const Gap(20),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeGrid(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: MessageThemeColor.values.map((themeOption) {
        final isSelected = themeOption == currentTheme;

        return GestureDetector(
          onTap: () async {
            // Save to Firestore
            await ref
                .read(messageRepositoryProvider)
                .setConversationTheme(
                  conversationId: conversationId,
                  userId: userId,
                  themeName: themeOption.name,
                );
            if (context.mounted) Navigator.pop(context);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: themeOption.color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: textPrimary, width: 3)
                      : Border.all(color: Colors.grey.shade200, width: 2),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: themeOption.color.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      )
                    : null,
              ),
              const Gap(8),
              Text(
                _formatThemeName(themeOption.name),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? textPrimary : textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Format theme name for display (e.g., "defaultColor" -> "Default")
  static String _formatThemeName(String name) {
    if (name == 'defaultColor') return 'Default';
    return name[0].toUpperCase() + name.substring(1);
  }
}
