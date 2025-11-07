// lib/auth/registration/steps/step_images.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/auth/registration/registration_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

/// CHANGE THESE TO YOUR CLOUDINARY VALUES
const String _cloudName = 'dcjhugzvs'; // ← e.g. "dxyz123"
const String _uploadPreset =
    'homify_unsigned'; // ← Must match Cloudinary preset

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
  final List<String> _localPaths = [];
  final List<String> _uploadedUrls = [];
  bool _isUploading = false;
  bool _triedNext = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final saved =
        ref.read(registrationControllerProvider).formData['imageUrls']
            as List<dynamic>?;
    if (saved != null) {
      _uploadedUrls.addAll(saved.cast<String>());
    }
  }

  Future<void> _pickImage() async {
    if (_localPaths.length + _uploadedUrls.length >= 5) return;

    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    setState(() {
      _localPaths.add(file.path);
      _triedNext = false;
    });

    await _uploadToCloudinary(file);
  }

  Future<void> _uploadToCloudinary(XFile file) async {
    setState(() => _isUploading = true);
    try {
      final cloudinary = CloudinaryPublic(_cloudName, _uploadPreset);
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      if (mounted) {
        setState(() {
          _uploadedUrls.add(response.secureUrl);
          _localPaths.remove(file.path);
          _saveToFormData();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: Check Cloudinary preset & internet'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _saveToFormData() {
    ref
        .read(registrationControllerProvider.notifier)
        .updateData('imageUrls', _uploadedUrls);
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedUrls.removeAt(index);
      _saveToFormData();
      _triedNext = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(registrationControllerProvider.notifier);
    final state = ref.watch(registrationControllerProvider);
    final isLastStep = state.currentStep == state.steps.length - 1;
    final isSubmitting = state.isSubmitting || _isUploading;
    final totalImages = _localPaths.length + _uploadedUrls.length;
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
                childAspectRatio: 1,
              ),
              itemCount: totalImages + (canAddMore ? 1 : 0),
              itemBuilder: (context, index) {
                // ADD BUTTON (first item if no photos)
                if (index == 0 && totalImages == 0 && canAddMore) {
                  return OutlinedButton(
                    onPressed: _isUploading ? null : _pickImage,
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

                // ADD BUTTON (after existing photos)
                if (index == totalImages && canAddMore) {
                  return OutlinedButton(
                    onPressed: _isUploading ? null : _pickImage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF32190D),
                      side: const BorderSide(color: Color(0xFF32190D)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.add, size: 32),
                  );
                }

                // Local (uploading)
                final localIndex = index - _uploadedUrls.length;
                if (localIndex >= 0 && localIndex < _localPaths.length) {
                  return _buildImagePreview(
                    File(_localPaths[localIndex]),
                    isUploading: true,
                  );
                }

                // Uploaded
                final urlIndex = index < _uploadedUrls.length
                    ? index
                    : index - _localPaths.length;
                return _buildImagePreview(
                  NetworkImage(_uploadedUrls[urlIndex]),
                );
              },
            ),
          ),

          const SizedBox(height: 24), // ← 24px gap
          // === DIVIDER ===
          const Divider(height: 1, thickness: 1, color: Colors.grey),

          const SizedBox(height: 24), // ← 24px after divider
          // === ERROR ===
          if (_triedNext && _uploadedUrls.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Please upload at least one photo.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          // === BUTTONS ===
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
                              if (_uploadedUrls.isEmpty) return;

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
              );
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildImagePreview(dynamic source, {bool isUploading = false}) {
    return GestureDetector(
      onTap: () {
        final index = _uploadedUrls.indexWhere(
          (url) => url == (source is NetworkImage ? source.url : null),
        );
        if (index != -1) _showRemoveDialog(index);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            source is File
                ? Image.file(source, fit: BoxFit.cover)
                : Image(image: source, fit: BoxFit.cover),
            if (isUploading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            // Remove button (on tap)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    final index = _uploadedUrls.indexWhere(
                      (url) =>
                          url == (source is NetworkImage ? source.url : null),
                    );
                    if (index != -1) _showRemoveDialog(index);
                  },
                ),
              ),
            ),
            // Remove icon
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Photo?'),
        content: const Text('This photo will be deleted permanently.'),
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
