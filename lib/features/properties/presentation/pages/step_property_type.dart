// lib/auth/registration/steps/step_property_type.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/core/entities/property_entity.dart';
import '../../../auth/presentation/controllers/registration_controller.dart';

/// Registration step – Owner chooses the type of property they are listing.
RegistrationStep stepPropertyType() {
  return RegistrationStep(
    title: 'Property Type',
    builder: (context) => const _PropertyTypeStep(),
    // Must pick one → Next disabled until chosen
    validate: (data) async => data['property_type'] != null,
  );
}

class _PropertyTypeStep extends ConsumerStatefulWidget {
  const _PropertyTypeStep();

  @override
  ConsumerState<_PropertyTypeStep> createState() => _PropertyTypeStepState();
}

class _PropertyTypeStepState extends ConsumerState<_PropertyTypeStep> {
  PropertyType? _selected;
  bool _triedNext = false; // <-- NEW: show error only after tapping Next

  @override
  void initState() {
    super.initState();
    _loadSavedSelection();
  }

  void _loadSavedSelection() {
    final saved =
        ref.read(registrationControllerProvider).formData['property_type']
            as String?;
    if (saved != null) {
      _selected = PropertyType.values.firstWhere(
        (e) => e.name == saved,
        orElse: () => _selected ?? PropertyType.values.first,
      );
    }
  }

  void _select(PropertyType? value) {
    if (value == null) return;
    setState(() {
      _selected = value;
      _triedNext = false; // hide error when user picks something
    });
    ref
        .read(registrationControllerProvider.notifier)
        .updateData('property_type', value.name);
  }

  Widget buildPropertyType(String title, PropertyType propertyType) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF32190D)),
      ),
      trailing: Radio<PropertyType>(
        value: propertyType,
        activeColor: Color(0xFF32190D),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationControllerProvider);

    // Keep UI in sync when navigating back
    final saved = state.formData['property_type'] as String?;
    if (saved != null && _selected?.name != saved) {
      _selected = PropertyType.values.firstWhere((e) => e.name == saved);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // ---- Header -------------------------------------------------
          Text(
            'What type of property are you listing?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF32190D),
            ),
          ),
          const SizedBox(height: 4),

          // ---- Sub-header ---------------------------------------------
          Text(
            'Choose the option that best describes your boarding house — like a room, bedspace, or whole house for rent.',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),

          // ---- Radio Card ---------------------------------------------
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
                RadioGroup<PropertyType>(
                  groupValue: _selected,
                  onChanged: (v) => _select(v),
                  child: Column(
                    children: <Widget>[
                      buildPropertyType('Bedspacer', PropertyType.bedspacer),
                      buildPropertyType('Room For Rent', PropertyType.room),
                      buildPropertyType('House For Rent', PropertyType.house),
                      buildPropertyType(
                        'Apartment Unit',
                        PropertyType.apartment,
                      ),
                      buildPropertyType('Dormitory', PropertyType.dormitory),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---- Error message (only after trying to go forward) ----
          if (_triedNext && _selected == null)
            const Padding(
              padding: EdgeInsets.only(top: 8, left: 20),
              child: Text(
                'Please select a property type.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          const SizedBox(height: 24),

          // ---- Buttons ------------------------------------------------
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
                              setState(() => _triedNext = true);
                              if (_selected == null) {
                                return; // error already shown
                              }
                              final ok = await controller.next();
                              if (!ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select a property type.',
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

          const Spacer(),
        ],
      ),
    );
  }
}
