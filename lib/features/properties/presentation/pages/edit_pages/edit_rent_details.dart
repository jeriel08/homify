import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/presentation/providers/owner_dashboard_provider.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';

class EditRentDetails extends ConsumerStatefulWidget {
  final PropertyEntity property;

  const EditRentDetails({super.key, required this.property});

  @override
  ConsumerState<EditRentDetails> createState() => _EditRentDetailsState();
}

class _EditRentDetailsState extends ConsumerState<EditRentDetails> {
  late final TextEditingController _rentCtrl;
  bool _triedSave = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _rentCtrl = TextEditingController(
      text: widget.property.rentAmount.toInt().toString(),
    );
  }

  @override
  void dispose() {
    _rentCtrl.dispose();
    super.dispose();
  }

  String? _rentError() {
    if (!_triedSave) return null;
    final v = _rentCtrl.text.trim();
    if (v.isEmpty) return 'Enter rent amount';
    final amount = int.tryParse(v);
    if (amount == null || amount <= 0) return 'Enter a valid amount';
    return null;
  }

  Future<void> _save() async {
    setState(() => _triedSave = true);

    final rentError = _rentError();

    if (rentError != null) {
      if (mounted) {
        DelightToastBar(
          position: DelightSnackbarPosition.top,
          snackbarDuration: const Duration(seconds: 3),
          autoDismiss: true,
          builder: (context) => const ToastCard(
            color: Colors.orange,
            leading: Icon(Icons.warning, size: 28, color: Colors.white),
            title: Text(
              'Please enter a valid rent amount',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ).show(context);
      }
      return;
    }

    setState(() => _isSaving = true);

    // Call update property from provider
    await ref
        .read(ownerDashboardProvider.notifier)
        .updateProperty(widget.property.id, {
          'rentAmount': double.parse(_rentCtrl.text.trim()),
          'rentChargeMethod': RentChargeMethod.perMonth.name,
        });

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
            'Rent details updated',
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
    final rentError = _rentError();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(
          'Edit Rent Details',
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
                    "Update rent amount",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF32190D),
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    "Set the monthly rent for this property.",
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Rent Amount
                  TextField(
                    controller: _rentCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Monthly rent amount',
                      hintText: 'e.g. 8500',
                      prefixText: '₱ ',
                      errorText: rentError,
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
