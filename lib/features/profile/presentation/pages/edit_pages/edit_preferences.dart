import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/features/profile/presentation/providers/profile_provider.dart';
import 'package:intl/intl.dart';

const List<String> kTenantDealbreakers = [
  'Must have Wi-Fi',
  'Aircon',
  'No Curfew',
  'Visitors Allowed',
  'Private CR',
  'Cooking Allowed',
  'Pet Friendly',
];

class EditPreferencesPage extends ConsumerStatefulWidget {
  final String userId;

  const EditPreferencesPage({super.key, required this.userId});

  @override
  ConsumerState<EditPreferencesPage> createState() =>
      _EditPreferencesPageState();
}

class _EditPreferencesPageState extends ConsumerState<EditPreferencesPage> {
  final _formKey = GlobalKey<FormState>();
  List<String> _selectedDealbreakers = [];
  RangeValues _budgetRange = const RangeValues(3000, 10000);
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final profileAsync = ref.read(userProfileStreamProvider(widget.userId));

    profileAsync.when(
      data: (profile) {
        if (mounted && profile.preferences != null) {
          setState(() {
            if (profile.preferences!['dealbreakers'] != null) {
              _selectedDealbreakers = List<String>.from(
                profile.preferences!['dealbreakers'],
              );
            }
            if (profile.preferences!['min_budget'] != null &&
                profile.preferences!['max_budget'] != null) {
              _budgetRange = RangeValues(
                (profile.preferences!['min_budget'] as num).toDouble(),
                (profile.preferences!['max_budget'] as num).toDouble(),
              );
            }
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      },
      loading: () {},
      error: (_, _) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
    );
  }

  String formatMoney(double val) =>
      '₱${NumberFormat('#,###').format(val.toInt())}';

  Future<void> _savePreferences() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> preferences = {
        'dealbreakers': _selectedDealbreakers,
        'min_budget': _budgetRange.start.toInt(),
        'max_budget': _budgetRange.end.toInt(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'preferences': preferences});

      // No need to invalidate - stream updates automatically
      // ref.invalidate(userProfileStreamProvider(widget.userId));

      if (mounted) {
        DelightToastBar(
          position: DelightSnackbarPosition.top,
          snackbarDuration: const Duration(seconds: 3),
          autoDismiss: true,
          builder: (context) => const ToastCard(
            color: Colors.green,
            leading: Icon(Icons.check_circle, size: 28, color: Colors.white),
            title: Text(
              'Preferences updated successfully!',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ).show(context);

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) context.pop();
        });
      }
    } catch (e) {
      if (mounted) {
        DelightToastBar(
          position: DelightSnackbarPosition.top,
          snackbarDuration: const Duration(seconds: 3),
          autoDismiss: true,
          builder: (context) => ToastCard(
            color: Colors.red,
            leading: const Icon(
              Icons.error_outline,
              size: 28,
              color: Colors.white,
            ),
            title: Text(
              'Failed to update preferences: ${e.toString()}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ).show(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Preferences',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF32190D),
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primary,
        elevation: 6,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.2),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text(
                        'Any must-haves?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF32190D),
                        ),
                      ),
                      const Gap(8),
                      const Text(
                        "We'll highlight properties that match these.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Gap(32),

                      // Dealbreakers
                      Wrap(
                        spacing: 8,
                        runSpacing: 12,
                        children: kTenantDealbreakers.map((item) {
                          final isSelected = _selectedDealbreakers.contains(
                            item,
                          );
                          return FilterChip(
                            label: Text(item),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() {
                                if (isSelected) {
                                  _selectedDealbreakers.remove(item);
                                } else {
                                  _selectedDealbreakers.add(item);
                                }
                              });
                            },
                            selectedColor: const Color(0xFFFFEDD4),
                            checkmarkColor: const Color(0xFF32190D),
                            labelStyle: TextStyle(
                              color: const Color(0xFF32190D),
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          );
                        }).toList(),
                      ),
                      const Gap(40),

                      // Budget Range
                      const Text(
                        "What's your monthly budget?",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF32190D),
                        ),
                      ),
                      const Gap(8),
                      const Text(
                        "Find a place that fits your allowance.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Gap(40),

                      // Range Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatMoney(_budgetRange.start),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE05725),
                            ),
                          ),
                          const Text("-", style: TextStyle(color: Colors.grey)),
                          Text(
                            formatMoney(_budgetRange.end),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE05725),
                            ),
                          ),
                        ],
                      ),
                      const Gap(20),

                      RangeSlider(
                        values: _budgetRange,
                        min: 500,
                        max: 20000,
                        divisions: 39,
                        activeColor: const Color(0xFFE05725),
                        onChanged: (val) {
                          setState(() {
                            _budgetRange = val;
                          });
                        },
                      ),
                      const Gap(40),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: !_isSaving ? _savePreferences : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
