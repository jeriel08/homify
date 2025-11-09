// lib/auth/registration/steps/step_rent_amount.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/properties/presentation/controllers/add_property_controller.dart';
import 'package:homify/features/properties/presentation/controllers/add_property_state.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

PropertyStep stepRentAmount() {
  return PropertyStep(
    title: 'Rent Amount',
    builder: (context) => const _RentAmountStep(),
    validate: (data) async {
      final amount = data['rent_amount'] as num?;
      return amount != null && amount > 0;
    },
  );
}

class _RentAmountStep extends ConsumerStatefulWidget {
  const _RentAmountStep();

  @override
  ConsumerState<_RentAmountStep> createState() => _RentAmountStepState();
}

class _RentAmountStepState extends ConsumerState<_RentAmountStep> {
  final TextEditingController _ctrl = TextEditingController();
  bool _triedNext = false;

  @override
  void initState() {
    super.initState();
    final saved =
        ref.read(addPropertyControllerProvider).formData['rent_amount'] as num?;
    if (saved != null) {
      _ctrl.text = saved.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _update(String value) {
    final num? parsed = num.tryParse(value);
    ref
        .read(addPropertyControllerProvider.notifier)
        .updateData('rent_amount', parsed);
    if (_triedNext) setState(() => _triedNext = false);
  }

  String? _error() {
    if (!_triedNext) return null;
    final value = num.tryParse(_ctrl.text);
    if (value == null || value <= 0) return 'Enter a valid amount';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(addPropertyControllerProvider.notifier);
    final state = ref.watch(addPropertyControllerProvider);
    final isLastStep = state.currentStep == state.steps.length - 1;
    final isSubmitting = state.isSubmitting;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          Text(
            'How much is the rent?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF32190D),
            ),
          ),
          const SizedBox(height: 24),

          // ---- Amount Input ----
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Rent amount',
              hintText: '1500',
              prefixIcon: Icon(LucideIcons.philippinePeso, size: 20),
              errorText: _error(),
              errorStyle: const TextStyle(color: Colors.red),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF32190D)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF32190D),
                  width: 2,
                ),
              ),
            ),
            cursorColor: const Color(0xFF32190D),
            onChanged: _update,
          ),

          const SizedBox(height: 24),

          // ---- Buttons ----
          Consumer(
            builder: (context, ref, child) {
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setState(() => _triedNext = true);
                              if (_error() != null) return;

                              final ok = await controller.next();
                              if (!ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a valid amount',
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF32190D),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(isLastStep ? 'Submit' : 'Next'),
                    ),
                  ),

                  if (state.currentStep > 0) const SizedBox(height: 8),
                  if (state.currentStep > 0)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: isSubmitting ? null : controller.back,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF32190D),
                          side: const BorderSide(color: Color(0xFF32190D)),
                          minimumSize: const Size.fromHeight(44),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                ],
              );
            },
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
