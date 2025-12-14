import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/core/utils/toast_helper.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/presentation/providers/owner_dashboard_provider.dart';

class EditPropertyType extends ConsumerStatefulWidget {
  final PropertyEntity property;

  const EditPropertyType({super.key, required this.property});

  @override
  ConsumerState<EditPropertyType> createState() => _EditPropertyTypeState();
}

class _EditPropertyTypeState extends ConsumerState<EditPropertyType> {
  late PropertyType _selectedType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.property.type;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    // Call update property from provider
    await ref.read(ownerDashboardProvider.notifier).updateProperty(
      widget.property.id,
      {'type': _selectedType.name},
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ToastHelper.success(context, 'Property type updated');
    }
  }

  String _formatType(PropertyType type) {
    return type.name
        .replaceAll('_', ' ')
        .split(' ')
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(
          'Edit Property Type',
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
                    "What type of property is this?",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF32190D),
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    "Select the category that best describes your property.",
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Property Type Radio Card
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(
                        color: Color(0xFF32190D),
                        width: 2,
                      ),
                    ),
                    color: const Color(0xFFFFEDD4),
                    child: RadioGroup<PropertyType>(
                      groupValue: _selectedType,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                      child: Column(
                        children: PropertyType.values.map((type) {
                          return ListTile(
                            title: Text(
                              _formatType(type),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF32190D),
                              ),
                            ),
                            trailing: Radio<PropertyType>(
                              value: type,
                              activeColor: const Color(0xFF32190D),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
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
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
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
