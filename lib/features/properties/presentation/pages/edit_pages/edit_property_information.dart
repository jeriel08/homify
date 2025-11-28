import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/presentation/providers/owner_dashboard_provider.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';

class EditPropertyInformation extends ConsumerStatefulWidget {
  final PropertyEntity property;

  const EditPropertyInformation({super.key, required this.property});

  @override
  ConsumerState<EditPropertyInformation> createState() =>
      _EditPropertyInformationState();
}

class _EditPropertyInformationState
    extends ConsumerState<EditPropertyInformation> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  bool _triedSave = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.property.name);
    _descCtrl = TextEditingController(text: widget.property.description);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  String? _nameError() {
    if (!_triedSave) return null;
    final v = _nameCtrl.text.trim();
    return v.isEmpty ? 'Enter a property name' : null;
  }

  String? _descError() {
    if (!_triedSave) return null;
    final v = _descCtrl.text.trim();
    return v.isEmpty ? 'Enter a description' : null;
  }

  Future<void> _save() async {
    setState(() => _triedSave = true);

    final nameError = _nameError();
    final descError = _descError();

    if (nameError != null || descError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields correctly')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Call update property from provider
    await ref.read(ownerDashboardProvider.notifier).updateProperty(
      widget.property.id,
      {'name': _nameCtrl.text.trim(), 'description': _descCtrl.text.trim()},
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      DelightToastBar(
        position: DelightSnackbarPosition.top,
        snackbarDuration: const Duration(seconds: 3),
        autoDismiss: true,
        builder: (context) => const ToastCard(
          color: Colors.green,
          leading: Icon(Icons.check_circle, size: 28, color: Colors.white),
          title: Text(
            'Property information updated',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nameError = _nameError();
    final descError = _descError();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(
          'Edit Property Information',
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
                    "Update your property's name and description",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF32190D),
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    "Make sure the information accurately describes your property.",
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Property Name
                  TextField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
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
                  ),

                  const SizedBox(height: 20),

                  // Description
                  TextField(
                    controller: _descCtrl,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
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
                  ),

                  const SizedBox(height: 32),
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
