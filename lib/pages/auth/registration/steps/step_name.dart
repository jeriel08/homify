// lib/auth/registration/steps/step_name.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../registration_controller.dart';

/// Step 2 – First & Last Name
RegistrationStep stepName() {
  return RegistrationStep(
    title: 'Name',
    builder: (context) => const _NameStep(),
    validate: (data) async {
      final first = (data['first_name'] as String?)?.trim();
      final last = (data['last_name'] as String?)?.trim();
      return first != null &&
          first.isNotEmpty &&
          last != null &&
          last.isNotEmpty;
    },
  );
}

class _NameStep extends ConsumerStatefulWidget {
  const _NameStep();

  @override
  ConsumerState<_NameStep> createState() => _NameStepState();
}

class _NameStepState extends ConsumerState<_NameStep> {
  late TextEditingController _firstCtrl;
  late TextEditingController _lastCtrl;

  @override
  void initState() {
    super.initState();
    _firstCtrl = TextEditingController();
    _lastCtrl = TextEditingController();

    // Pre-fill if data exists (e.g., coming back)
    final data = ref.read(registrationControllerProvider).formData;
    _firstCtrl.text = data['first_name'] ?? '';
    _lastCtrl.text = data['last_name'] ?? '';
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(registrationControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          Text(
            'What’s your name?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF32190D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your full name as it appears on your ID.',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 32),

          // First Name
          TextField(
            controller: _firstCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'First Name',
              hintText: 'Juan',
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
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
            onChanged: (v) => controller.updateData('first_name', v.trim()),
          ),
          const SizedBox(height: 20),

          // Last Name
          TextField(
            controller: _lastCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Last Name',
              hintText: 'Dela Cruz',
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
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
            onChanged: (v) => controller.updateData('last_name', v.trim()),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
