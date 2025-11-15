// lib/auth/registration/steps/step_amenities.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/properties/presentation/controllers/add_property_controller.dart';
import 'package:homify/features/properties/presentation/controllers/add_property_state.dart';

/// All possible amenities – grouped by category
final Map<String, List<String>> _amenityGroups = {
  'Basic Room Features': [
    'Bunk Bed',
    'Fan Room',
    'Aircon Room',
    'Private Bathroom',
    'Study Area',
    'Cabinets',
  ],
  'Utilities & Essentials': [
    'Water Supply 24/7',
    'Separate Electricity Meter',
    'Wi-Fi',
    'Laundry Area',
    'Washing Area',
    'Shared Kitchen',
    'Common Sink Area',
  ],
  'Safety & Security': [
    'Gated Property',
    'CCTV Cameras',
    'Curfew',
    'Owner/Landlord On-site',
    'Fire Extinguisher',
    'Emergency Exit',
  ],
  'Shared/Common Facilities': [
    'Common Area/Lounge',
    'Dining Area',
    'Clothesline Area',
    'Parking',
  ],
  'Rules or Perks': [
    'Visitors Allowed',
    'Pet-friendly',
    'Couples Allowed',
    'Separate for Male/Female',
  ],
};

PropertyStep stepAmenities() {
  return PropertyStep(
    title: 'Amenities',
    builder: (context) => const _AmenitiesStep(),
    validate: (data) async {
      final amenities = data['amenities'] as List<String>?;
      return amenities != null && amenities.isNotEmpty;
    },
  );
}

class _AmenitiesStep extends ConsumerStatefulWidget {
  const _AmenitiesStep();

  @override
  ConsumerState<_AmenitiesStep> createState() => _AmenitiesStepState();
}

class _AmenitiesStepState extends ConsumerState<_AmenitiesStep> {
  final Set<String> _selected = {};
  bool _triedNext = false;

  @override
  void initState() {
    super.initState();
    final saved =
        ref.read(addPropertyControllerProvider).formData['amenities']
            as List<dynamic>?;
    if (saved != null) {
      _selected.addAll(saved.cast<String>());
    }
  }

  void _toggle(String amenity) {
    setState(() {
      if (_selected.contains(amenity)) {
        _selected.remove(amenity);
      } else {
        _selected.add(amenity);
      }
      _triedNext = false;
    });
    ref
        .read(addPropertyControllerProvider.notifier)
        .updateData('amenities', _selected.toList());
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

          // Header
          Text(
            'What amenities do you offer?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF32190D),
            ),
          ),
          const SizedBox(height: 4),

          // Subheader
          Text(
            'Select the features and facilities available in your boarding house.',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),

          // Scrollable list of amenity groups
          Expanded(
            child: ListView.separated(
              itemCount: _amenityGroups.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final entry = _amenityGroups.entries.elementAt(index);
                final category = entry.key;
                final items = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category title
                    Text(
                      category,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF32190D),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: items.map((amenity) {
                        final isSelected = _selected.contains(amenity);
                        return FilterChip(
                          label: Text(amenity),
                          selected: isSelected,
                          onSelected: (_) => _toggle(amenity),
                          selectedColor: const Color(0xFFFFEDD4),
                          checkmarkColor: const Color(0xFF32190D),
                          backgroundColor: Color(0xFFFFEDD4),
                          labelStyle: TextStyle(
                            color: const Color(0xFF32190D),
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF32190D)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // Divider after every group EXCEPT the last one
                    if (index < _amenityGroups.length - 1) ...[
                      const SizedBox(height: 24),
                      const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 4),
                    ],
                  ],
                );
              },
            ),
          ),

          // Error message
          if (_triedNext && _selected.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Please select at least one amenity.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          const SizedBox(height: 24),

          // Buttons
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
                              if (_selected.isEmpty) return;

                              final ok = await controller.next();
                              if (!ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please select at least one amenity',
                                    ),
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

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
