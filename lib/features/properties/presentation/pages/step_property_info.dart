// lib/auth/registration/steps/step_property_info.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/auth/presentation/controllers/registration_controller.dart';

/// Returns the RegistrationStep for the Owner property-info screen.
RegistrationStep stepPropertyInfo() {
  return RegistrationStep(
    title: 'Property Info',
    builder: (context) => const _PropertyInfoStep(),
    validate: (data) async {
      final name = data['property_name'] as String?;
      final desc = data['property_description'] as String?;

      return (name?.isNotEmpty ?? false) && (desc?.isNotEmpty ?? false);
    },
  );
}

class _PropertyInfoStep extends ConsumerStatefulWidget {
  const _PropertyInfoStep();

  @override
  ConsumerState<_PropertyInfoStep> createState() => _PropertyInfoStepState();
}

class _PropertyInfoStepState extends ConsumerState<_PropertyInfoStep> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;

  bool _triedNext = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _descCtrl = TextEditingController();

    final data = ref.read(registrationControllerProvider).formData;
    _nameCtrl.text = data['property_name'] ?? '';
    _descCtrl.text = data['property_description'] ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _update(String key, String value) {
    ref.read(registrationControllerProvider.notifier).updateData(key, value);
  }

  String? _nameError() {
    if (!_triedNext) return null;
    final v = _nameCtrl.text.trim();
    return v.isEmpty ? 'Enter a property name' : null;
  }

  String? _descError() {
    if (!_triedNext) return null;
    final v = _descCtrl.text.trim();
    return v.isEmpty ? 'Enter a short description' : null;
  }

  @override
  Widget build(BuildContext context) {
    final nameError = _nameError();
    final descError = _descError();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // ---- Header -------------------------------------------------
            Text(
              "What’s the name of your property?",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF32190D),
              ),
            ),
            const SizedBox(height: 4),

            Text(
              "Give your boarding house a name and short description so tenants know what to expect.",
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),

            // ---- Property Name -----------------------------------------
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Property name',
                hintText: 'e.g. Sunny Hills Boarding House',
                errorText: nameError,
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
                  borderSide: const BorderSide(
                    color: Color(0xFF32190D),
                    width: 1,
                  ),
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
              onChanged: (v) => _update('property_name', v.trim()),
            ),

            const SizedBox(height: 16),

            // ---- Description -------------------------------------------
            TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText:
                    'e.g. Cozy rooms, free Wi-Fi, 5-min walk to campus...',
                errorText: descError,
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
                  borderSide: const BorderSide(
                    color: Color(0xFF32190D),
                    width: 1,
                  ),
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
              onChanged: (v) => _update('property_description', v.trim()),
            ),

            const SizedBox(height: 20),

            // ---- Buttons (identical to step_password) -----------------
            Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(registrationControllerProvider);
                final controller = ref.read(
                  registrationControllerProvider.notifier,
                );
                final isLastStep = state.currentStep == state.steps.length - 1;
                final isSubmitting = state.isSubmitting;

                return Column(
                  children: [
                    // NEXT / SUBMIT
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                // Force validation UI update
                                setState(() => _triedNext = true);

                                if (nameError != null || descError != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please fill in both fields correctly',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                final ok = await controller.next();
                                if (!ok && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Validation failed'),
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
                            : Text(
                                isLastStep ? 'Submit' : 'Next',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),

                    if (state.currentStep > 0) const SizedBox(height: 8),

                    // BACK
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
                          child: const Text(
                            'Back',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
