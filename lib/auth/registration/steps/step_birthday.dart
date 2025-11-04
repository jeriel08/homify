// lib/auth/registration/steps/step_birthday.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../registration_controller.dart';

RegistrationStep stepBirthday() {
  return RegistrationStep(
    title: 'Birthday',
    builder: (context) => const _BirthdayStep(),
    validate: (data) async {
      final dateStr = data['birthday'] as String?;
      if (dateStr == null) return false;
      try {
        final date = DateFormat('yyyy-MM-dd').parseStrict(dateStr);
        final age = DateTime.now().difference(date).inDays ~/ 365;
        return age >= 18;
      } catch (e) {
        return false;
      }
    },
  );
}

class _BirthdayStep extends ConsumerStatefulWidget {
  const _BirthdayStep();

  @override
  ConsumerState<_BirthdayStep> createState() => _BirthdayStepState();
}

class _BirthdayStepState extends ConsumerState<_BirthdayStep> {
  late TextEditingController _dateCtrl;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _dateCtrl = TextEditingController();
    final data = ref.read(registrationControllerProvider).formData;
    final saved = data['birthday'] as String?;
    if (saved != null) {
      _selectedDate = DateFormat('yyyy-MM-dd').parseStrict(saved);
      _dateCtrl.text = DateFormat('MMMM d, yyyy').format(_selectedDate!);
    } else {
      _selectedDate = DateTime.now();
      _dateCtrl.text = DateFormat('MMMM d, yyyy').format(_selectedDate!);
    }

    // Auto-open calendar on step enter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showDatePicker();
    });
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF32190D)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateCtrl.text = DateFormat('MMMM d, yyyy').format(picked);
      });
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      ref
          .read(registrationControllerProvider.notifier)
          .updateData('birthday', formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          Text(
            'When’s your birthday?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF32190D),
            ),
          ),
          const SizedBox(height: 24),

          // Date Input
          TextField(
            controller: _dateCtrl,
            readOnly: true,
            onTap: _showDatePicker,
            decoration: InputDecoration(
              labelText: 'Birthday',
              hintText: 'Select your birthday',
              suffixIcon: const Icon(
                LucideIcons.calendar,
                color: Color(0xFF32190D),
              ),
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
          ),

          const SizedBox(height: 24),

          // Buttons moved here (from registration.dart)
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(registrationControllerProvider);
              final controller = ref.read(
                registrationControllerProvider.notifier,
              );

              return Column(
                children: [
                  // Next / Submit Button
                  SizedBox(
                    width: double.infinity, // Full width
                    child: ElevatedButton(
                      onPressed: () async {
                        final ok = await controller.next();
                        if (!ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You must be 18 or older'),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF32190D),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(
                        state.currentStep == state.steps.length - 1
                            ? 'Submit'
                            : 'Next',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),

                  // Space between buttons
                  if (state.currentStep > 0) const SizedBox(height: 12),

                  // Back Button (only if not first step)
                  if (state.currentStep > 0)
                    SizedBox(
                      width: double.infinity, // Full width
                      child: OutlinedButton(
                        onPressed: controller.back,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF32190D),
                          side: const BorderSide(color: Color(0xFF32190D)),
                          minimumSize: const Size.fromHeight(48),
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

          const Spacer(),
        ],
      ),
    );
  }
}
