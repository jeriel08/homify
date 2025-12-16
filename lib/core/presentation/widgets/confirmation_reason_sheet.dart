import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/core/theme/typography.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ConfirmationReasonSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> reasons;
  final Function(String reason) onConfirm;
  final String confirmLabel;
  final IconData confirmIcon;
  final Color confirmColor;
  final bool isProcessing;

  const ConfirmationReasonSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.reasons,
    required this.onConfirm,
    required this.confirmLabel,
    this.confirmIcon = LucideIcons.check,
    this.confirmColor = AppColors.primary,
    this.isProcessing = false,
  });

  @override
  State<ConfirmationReasonSheet> createState() =>
      _ConfirmationReasonSheetState();
}

class _ConfirmationReasonSheetState extends State<ConfirmationReasonSheet> {
  String? _selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();
  bool _showOtherInput = false;

  @override
  void dispose() {
    _otherReasonController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_selectedReason == null) return;

    String finalReason = _selectedReason!;
    if (_selectedReason == 'Other') {
      if (_otherReasonController.text.trim().isEmpty) return;
      finalReason = _otherReasonController.text.trim();
    }

    widget.onConfirm(finalReason);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(24),
          Text(
            widget.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const Gap(8),
          Text(
            widget.subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const Gap(24),
          ...widget.reasons.map((reason) => _buildReasonOption(reason)),

          if (_showOtherInput) ...[
            const Gap(12),
            TextField(
              controller: _otherReasonController,
              decoration: InputDecoration(
                hintText: 'Please specify...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 2,
            ),
          ],

          const Gap(32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (widget.isProcessing || _selectedReason == null)
                  ? null
                  : _handleConfirm,
              style: FilledButton.styleFrom(
                backgroundColor: widget.confirmColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: widget.isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Icon(widget.confirmIcon, size: 20),
              label: Text(
                widget.isProcessing ? 'Processing...' : widget.confirmLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonOption(String reason) {
    final isSelected = _selectedReason == reason;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedReason = reason;
            _showOtherInput = reason == 'Other';
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.05)
                : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : Colors.grey.shade400,
                size: 20,
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  reason,
                  style: HomifyTypography.body2.copyWith(
                    color: isSelected ? AppColors.primary : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
