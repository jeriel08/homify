// lib/auth/registration/steps/step_rent_method.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/models/property_model.dart';
import '../../registration_controller.dart';

RegistrationStep stepRentMethod() {
  return RegistrationStep(
    title: 'Rent Charge Method',
    builder: (context) => const _RentMethodStep(),
    validate: (data) async => data['rent_charge_method'] != null,
  );
}

class _RentMethodStep extends ConsumerStatefulWidget {
  const _RentMethodStep();

  @override
  ConsumerState<_RentMethodStep> createState() => _RentMethodStepState();
}

class _RentMethodStepState extends ConsumerState<_RentMethodStep> {
  RentChargeMethod? _selected;
  bool _triedNext = false;

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  void _loadSaved() {
    final saved =
        ref.read(registrationControllerProvider).formData['rent_charge_method']
            as String?;
    if (saved != null) {
      _selected = RentChargeMethod.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => RentChargeMethod.values.first,
      );
    }
  }

  void _select(RentChargeMethod? value) {
    if (value == null) return;
    setState(() {
      _selected = value;
      _triedNext = false;
    });
    ref
        .read(registrationControllerProvider.notifier)
        .updateData('rent_charge_method', value.name);
  }

  Widget buildRadioTiles(String title, RentChargeMethod rentChargeMethod) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF32190D)),
      ),
      trailing: Radio<RentChargeMethod>(
        value: rentChargeMethod,
        activeColor: Color(0xFF32190D),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(registrationControllerProvider.notifier);
    final state = ref.watch(registrationControllerProvider);
    final isLastStep = state.currentStep == state.steps.length - 1;
    final isSubmitting = state.isSubmitting;

    // Sync if user navigates back
    final saved = state.formData['rent_charge_method'] as String?;
    if (saved != null && _selected?.name != saved) {
      _selected = RentChargeMethod.values.firstWhere((e) => e.name == saved);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          Text(
            'How do you charge rent?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF32190D),
            ),
          ),
          const SizedBox(height: 4),

          Text(
            'Choose the method that best fits your boarding house.',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 32),

          // ---- Radio Card ----
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: const Color(0xFF32190D),
                width: _selected != null && !_triedNext ? 2 : 1,
              ),
            ),
            color: const Color(0xFFFFEDD4),
            child: Column(
              children: [
                RadioGroup<RentChargeMethod>(
                  onChanged: (v) => _select(v),
                  groupValue: _selected,
                  child: Column(
                    children: <Widget>[
                      buildRadioTiles('Per Person', RentChargeMethod.perPerson),
                      buildRadioTiles('Per Bed', RentChargeMethod.perBed),
                      buildRadioTiles('Per Room', RentChargeMethod.perRoom),
                      buildRadioTiles('Per Unit', RentChargeMethod.perUnit),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Error only after trying to go forward
          if (_triedNext && _selected == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Please select a rent charge method.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
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
                              if (_selected == null) return;

                              final ok = await controller.next();
                              if (!ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please select a method'),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF32190D),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
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

                  if (state.currentStep > 0) const SizedBox(height: 12),
                  if (state.currentStep > 0)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: isSubmitting ? null : controller.back,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF32190D),
                          side: const BorderSide(color: Color(0xFF32190D)),
                          minimumSize: const Size.fromHeight(48),
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
