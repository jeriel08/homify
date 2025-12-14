import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/core/utils/toast_helper.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/presentation/providers/owner_dashboard_provider.dart';

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

class EditAmenities extends ConsumerStatefulWidget {
  final PropertyEntity property;

  const EditAmenities({super.key, required this.property});

  @override
  ConsumerState<EditAmenities> createState() => _EditAmenitiesState();
}

class _EditAmenitiesState extends ConsumerState<EditAmenities> {
  final Set<String> _selected = {};
  bool _triedSave = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selected.addAll(widget.property.amenities);
  }

  void _toggle(String amenity) {
    setState(() {
      if (_selected.contains(amenity)) {
        _selected.remove(amenity);
      } else {
        _selected.add(amenity);
      }
      _triedSave = false;
    });
  }

  Future<void> _save() async {
    setState(() => _triedSave = true);

    if (_selected.isEmpty) {
      if (mounted) {
        ToastHelper.warning(context, 'Please select at least one amenity');
      }
      return;
    }

    setState(() => _isSaving = true);

    // Call update property from provider
    await ref.read(ownerDashboardProvider.notifier).updateProperty(
      widget.property.id,
      {'amenities': _selected.toList()},
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ToastHelper.success(context, 'Amenities updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(
          'Edit Amenities',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF32190D),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF9E5C5),
        foregroundColor: const Color(0xFF32190D),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Header
                  Text(
                    'What amenities do you offer?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF32190D),
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    'Select the features and facilities available in your boarding house.',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Amenity Groups
                  ..._amenityGroups.entries.map((entry) {
                    final category = entry.key;
                    final items = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category title
                        Text(
                          category,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
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
                              selectedColor: const Color(0xFFF9E5C5),
                              checkmarkColor: const Color(0xFF32190D),
                              backgroundColor: const Color(0xFFFFEDD4),
                              labelStyle: TextStyle(
                                color: const Color(0xFF32190D),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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

                        const SizedBox(height: 20),

                        // Divider
                        if (entry.key != _amenityGroups.keys.last)
                          Container(
                            height: 1,
                            color: Colors.grey.shade300,
                            margin: const EdgeInsets.only(bottom: 20),
                          ),
                      ],
                    );
                  }),

                  // Error message
                  if (_triedSave && _selected.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Please select at least one amenity.',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF32190D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
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
                        'Save Changes (${_selected.length} selected)',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
