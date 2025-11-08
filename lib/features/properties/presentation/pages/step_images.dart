import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/features/auth/presentation/controllers/registration_controller.dart';
import 'package:image_picker/image_picker.dart';

RegistrationStep stepImages() {
  return RegistrationStep(
    title: 'Property Photos',
    builder: (context) => const _ImagesStep(),
    validate: (data) async {
      final urls = data['imageUrls'] as List<String>?;
      return urls != null && urls.isNotEmpty;
    },
  );
}

class _ImagesStep extends ConsumerStatefulWidget {
  const _ImagesStep();

  @override
  ConsumerState<_ImagesStep> createState() => _ImagesStepState();
}

class _ImagesStepState extends ConsumerState<_ImagesStep> {
  final List<XFile> _localFiles = [];
  bool _triedNext = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final savedFiles =
        ref.read(registrationControllerProvider).formData['imageUrls']
            as List<File>?;
    if (savedFiles != null) {
      _localFiles.addAll(savedFiles.map((file) => XFile(file.path)));
    }
  }

  Future<void> _pickImage() async {
    if (_localFiles.length >= 5) return;

    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() {
      _localFiles.add(file);
      _triedNext = false;
    });

    _saveToFormData();
  }

  void _saveToFormData() {
    final fileList = _localFiles.map((xfile) => File(xfile.path)).toList();
    ref
        .read(registrationControllerProvider.notifier)
        .updateData('images', fileList);
  }

  void _removeImage(int index) {
    setState(() {
      _localFiles.removeAt(index);
      _saveToFormData();
      _triedNext = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(registrationControllerProvider.notifier);
    final state = ref.watch(registrationControllerProvider);
    final isLastStep = state.currentStep == state.steps.length - 1;
    final isSubmitting = state.isSubmitting;
    final totalImages = _localFiles.length;
    final canAddMore = totalImages < 5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Header
          Text(
            'Show us what your place looks like!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF32190D),
            ),
          ),
          const SizedBox(height: 4),

          // Subheader
          Text(
            'Upload up to 5 photos of your property — include rooms, outside view, and shared spaces so tenants can get a feel of it.',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),

          // === IMAGE GRID (starts at top-left) ===
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: totalImages + (canAddMore ? 1 : 0),
              itemBuilder: (context, index) {
                // ADD BUTTON (first item if no photos)
                if (index == totalImages) {
                  return OutlinedButton(
                    onPressed: isSubmitting ? null : _pickImage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF32190D),
                      side: const BorderSide(color: Color(0xFF32190D)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.add_a_photo, size: 32),
                  );
                }

                final file = _localFiles[index];
                return _buildImagePreview(file, index);
              },
            ),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1, color: Colors.grey),
          const SizedBox(height: 24),

          // === ERROR ===
          if (_triedNext && _localFiles.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Please upload at least one photo.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          // === BUTTONS ===
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() => _triedNext = true);
                          // CHANGED: Check local files list
                          if (_localFiles.isEmpty) return;

                          final ok = await controller.next();
                          if (!ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please upload at least one photo',
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
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildImagePreview(XFile file, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.red.withValues(alpha: 0.8),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () => _showRemoveDialog(index),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Photo?'),
        content: const Text('This photo will be removed from the selection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeImage(index);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
