import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homify/core/utils/toast_helper.dart';
import 'package:homify/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:homify/features/properties/domain/entities/property_entity.dart';
import 'package:homify/features/properties/presentation/providers/owner_dashboard_provider.dart';
import 'package:homify/features/properties/properties_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EditPropertyImages extends ConsumerStatefulWidget {
  final PropertyEntity property;

  const EditPropertyImages({super.key, required this.property});

  @override
  ConsumerState<EditPropertyImages> createState() => _EditPropertyImagesState();
}

class _EditPropertyImagesState extends ConsumerState<EditPropertyImages> {
  late List<String> _imageUrls;
  bool _isSaving = false;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imageUrls = List.from(widget.property.imageUrls);
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  Future<void> _addImage() async {
    if (_imageUrls.length >= 10) {
      if (mounted) {
        ToastHelper.warning(context, 'Maximum 10 images allowed');
      }
      return;
    }

    try {
      // Pick image from gallery
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      setState(() => _isUploading = true);

      // Get current user UID
      final userState = ref.read(authStateProvider);
      final ownerUid = userState.maybeWhen(
        data: (user) => user?.uid ?? widget.property.ownerUid,
        orElse: () => widget.property.ownerUid,
      );

      // Upload to Cloudinary
      final dataSource = ref.read(propertyRemoteDataSourceProvider);
      final urls = await dataSource.uploadImages([File(file.path)], ownerUid);

      if (urls.isNotEmpty && mounted) {
        setState(() {
          _imageUrls.add(urls.first);
          _isUploading = false;
        });

        ToastHelper.success(context, 'Image uploaded successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ToastHelper.error(context, 'Upload Failed', subtitle: e.toString());
      }
    }
  }

  Future<void> _save() async {
    if (_imageUrls.isEmpty) {
      if (mounted) {
        ToastHelper.warning(context, 'Please add at least one image');
      }
      return;
    }

    setState(() => _isSaving = true);

    // Call update property from provider
    await ref.read(ownerDashboardProvider.notifier).updateProperty(
      widget.property.id,
      {'imageUrls': _imageUrls},
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      ToastHelper.success(context, 'Images updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: Text(
          'Edit Images',
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
                    'Manage your property images',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF32190D),
                    ),
                  ),
                  const SizedBox(height: 4),

                  Text(
                    'Add, remove, or reorder photos. Maximum 10 images.',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Image counter
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9E5C5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF32190D),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.images,
                          color: Color(0xFF32190D),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_imageUrls.length} of 10 images',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF32190D),
                              ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Images Grid
                  if (_imageUrls.isEmpty)
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.imageOff,
                              size: 48,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No images yet',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                      itemCount: _imageUrls.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            // Image
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF32190D),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  _imageUrls[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (_, _, _) => Container(
                                    color: Colors.grey.shade300,
                                    child: const Center(
                                      child: Icon(
                                        LucideIcons.imageOff,
                                        size: 32,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Remove button
                            Positioned(
                              top: 8,
                              right: 8,
                              child: InkWell(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade700,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    LucideIcons.x,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),

                            // First image badge
                            if (index == 0)
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF32190D),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Cover Photo',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                  const SizedBox(height: 20),

                  // Add Image Button
                  if (_imageUrls.length < 10)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isUploading ? null : _addImage,
                        icon: _isUploading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(LucideIcons.plus, size: 20),
                        label: Text(
                          _isUploading ? 'Uploading...' : 'Add Image',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF32190D),
                          side: const BorderSide(
                            color: Color(0xFF32190D),
                            width: 2,
                          ),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
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
