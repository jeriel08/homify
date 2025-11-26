import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/features/profile/presentation/providers/profile_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class EditPersonalInformationPage extends ConsumerStatefulWidget {
  final String userId;

  const EditPersonalInformationPage({super.key, required this.userId});

  @override
  ConsumerState<EditPersonalInformationPage> createState() =>
      _EditPersonalInformationPageState();
}

class _EditPersonalInformationPageState
    extends ConsumerState<EditPersonalInformationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();

  String? _selectedOccupation;
  String? _selectedSchool;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEmailVerified = false;

  final List<String> _occupations = [
    'Student',
    'Working Professional',
    'Tourist / Traveler',
  ];

  final List<String> _schools = [
    'Ateneo de Davao University',
    'University of Mindanao (Matina)',
    'University of Mindanao (Bolton)',
    'USEP (Obrero)',
    'Davao Doctors College',
    'San Pedro College',
    'Brokenshire College',
    'Holy Cross of Davao College',
    'Mapúa Malayan Colleges Mindanao',
    'UIC (Main)',
    'UIC (Bajada)',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final profileAsync = ref.read(userProfileStreamProvider(widget.userId));

    profileAsync.when(
      data: (profile) {
        if (mounted) {
          setState(() {
            _emailController.text = profile.email;
            _mobileController.text = profile.mobile ?? '';
            _selectedOccupation = profile.occupation;
            _isEmailVerified = profile.isEmailVerified ?? false;

            // Handle school - if it's not in the list, add it to the list
            if (profile.school != null && profile.school!.isNotEmpty) {
              if (!_schools.contains(profile.school)) {
                _schools.insert(_schools.length - 1, profile.school!);
              }
              _selectedSchool = profile.school;
            }

            _isLoading = false;
          });
        }
      },
      loading: () {},
      error: (_, _) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    final emailValid =
        _emailController.text.trim().isNotEmpty &&
        RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text.trim());
    final mobileValid = _mobileController.text.trim().isNotEmpty;
    final occupationValid = _selectedOccupation != null;
    final schoolValid =
        _selectedOccupation != 'Student' || _selectedSchool != null;

    return emailValid && mobileValid && occupationValid && schoolValid;
  }

  Future<void> _saveInformation() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> updates = {
        'email': _emailController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'occupation': _selectedOccupation,
      };

      if (_selectedOccupation == 'Student') {
        updates['school'] = _selectedSchool;
      } else {
        updates['school'] = null;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update(updates);

      // No need to invalidate - stream updates automatically
      // ref.invalidate(userProfileStreamProvider(widget.userId));

      if (mounted) {
        DelightToastBar(
          position: DelightSnackbarPosition.top,
          snackbarDuration: const Duration(seconds: 3),
          autoDismiss: true,
          builder: (context) => const ToastCard(
            color: Colors.green,
            leading: Icon(Icons.check_circle, size: 28, color: Colors.white),
            title: Text(
              'Personal information updated successfully!',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ).show(context);

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) context.pop();
        });
      }
    } catch (e) {
      if (mounted) {
        DelightToastBar(
          position: DelightSnackbarPosition.top,
          snackbarDuration: const Duration(seconds: 3),
          autoDismiss: true,
          builder: (context) => ToastCard(
            color: Colors.red,
            leading: const Icon(
              Icons.error_outline,
              size: 28,
              color: Colors.white,
            ),
            title: Text(
              'Failed to update information: ${e.toString()}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ).show(context);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Edit Personal Information',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF32190D),
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primary,
        elevation: 6,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.2),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  onChanged: () => setState(() {}),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text(
                        'Update your details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF32190D),
                        ),
                      ),
                      const Gap(8),

                      // Subheader
                      const Text(
                        'Keep your personal information up to date for a better experience.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Gap(32),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          hintText: 'Enter your email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          suffixIcon: _isEmailVerified
                              ? const Icon(
                                  Icons.verified,
                                  color: Colors.green,
                                  size: 20,
                                )
                              : null,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const Gap(20),

                      // Mobile Number Field
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Mobile Number',
                          hintText: '+63 XXX XXX XXXX',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Mobile number is required';
                          }
                          return null;
                        },
                      ),
                      const Gap(32),

                      // Divider
                      const Divider(thickness: 1),
                      const Gap(24),

                      // Occupation Section
                      const Text(
                        'Occupation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF32190D),
                        ),
                      ),
                      const Gap(12),

                      // Occupation Choice Chips
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _occupations.map((occupation) {
                          final isSelected = _selectedOccupation == occupation;
                          return ChoiceChip(
                            label: Text(occupation),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedOccupation = occupation;
                                  if (occupation != 'Student') {
                                    _selectedSchool = null;
                                  }
                                }
                              });
                            },
                            selectedColor: const Color(0xFFE05725),
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF32190D),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey.shade300,
                              ),
                            ),
                            showCheckmark: false,
                          );
                        }).toList(),
                      ),
                      const Gap(24),

                      // Divider before school
                      if (_selectedOccupation == 'Student') ...[
                        const Divider(thickness: 1),
                        const Gap(24),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSchool,
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(16),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontFamily: 'Poppins',
                          ),
                          decoration: InputDecoration(
                            labelText: 'Select University/College',
                            labelStyle: const TextStyle(fontSize: 14),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Icon(
                              LucideIcons.graduationCap,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          items: _schools.map((school) {
                            return DropdownMenuItem(
                              value: school,
                              child: Text(
                                school,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSchool = value;
                            });
                          },
                          validator: (value) {
                            if (_selectedOccupation == 'Student' &&
                                value == null) {
                              return 'School is required for students';
                            }
                            return null;
                          },
                        ),
                        const Gap(24),
                      ],

                      // Final divider
                      const Divider(thickness: 1),
                      const Gap(24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: (_isFormValid && !_isSaving)
                              ? _saveInformation
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppColors.primary
                                .withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
