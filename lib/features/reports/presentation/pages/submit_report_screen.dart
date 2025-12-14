import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/theme/app_colors.dart';
import 'package:homify/core/utils/uuid_generator.dart';
import 'package:homify/core/presentation/widgets/step_progress_bar.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:homify/features/reports/presentation/pages/steps/report_details_step.dart';
import 'package:homify/features/reports/presentation/pages/steps/report_review_step.dart';
import 'package:homify/features/reports/presentation/pages/steps/report_type_step.dart';
import 'package:homify/features/reports/presentation/providers/report_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:homify/core/theme/typography.dart';

class SubmitReportScreen extends ConsumerStatefulWidget {
  final String? targetId;
  final String targetType;

  const SubmitReportScreen({
    super.key,
    this.targetId,
    required this.targetType,
  });

  @override
  ConsumerState<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends ConsumerState<SubmitReportScreen> {
  int _currentStep = 0;
  ReportType? _selectedType;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isReverse = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedType == null) {
      DelightToastBar(
        autoDismiss: true,
        snackbarDuration: const Duration(seconds: 3),
        position: DelightSnackbarPosition.top,
        builder: (context) => ToastCard(
          leading: Icon(
            LucideIcons.triangleAlert,
            size: 28,
            color: AppColors.error,
          ),
          title: Text(
            'Please select a report type',
            style: HomifyTypography.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          color: AppColors.error.withValues(alpha: 0.1),
        ),
      ).show(context);
      return;
    }
    if (_currentStep == 1) {
      if (!_formKey.currentState!.validate()) return;
    }
    setState(() {
      _isReverse = false;
      _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
      _isReverse = true;
      _currentStep--;
    });
  }

  Future<void> _submitReport() async {
    setState(() {
      _isSubmitting = true;
    });

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      DelightToastBar(
        autoDismiss: true,
        snackbarDuration: const Duration(seconds: 3),
        position: DelightSnackbarPosition.top,
        builder: (context) => ToastCard(
          leading: Icon(
            LucideIcons.triangleAlert,
            size: 28,
            color: AppColors.error,
          ),
          title: Text(
            'You must be logged in to submit a report',
            style: HomifyTypography.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          color: Colors.white,
        ),
      ).show(context);
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final report = ReportEntity(
      id: UuidGenerator.generate(),
      reporterId: currentUser.uid,
      targetId: widget.targetId,
      targetType: widget.targetType,
      type: _selectedType!,
      title: _titleController.text,
      description: _descriptionController.text,
      status: ReportStatus.pending,
      createdAt: DateTime.now(),
    );

    final submitReport = ref.read(submitReportUseCaseProvider);
    final result = await submitReport(report);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    result.fold(
      (failure) {
        DelightToastBar(
          autoDismiss: true,
          snackbarDuration: const Duration(seconds: 3),
          position: DelightSnackbarPosition.top,
          builder: (context) => ToastCard(
            leading: Icon(
              LucideIcons.triangleAlert,
              size: 28,
              color: AppColors.error,
            ),
            title: Text(
              'Failed to submit report: ${failure.message}',
              style: HomifyTypography.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            color: Colors.white,
          ),
        ).show(context);
      },
      (_) {
        DelightToastBar(
          autoDismiss: true,
          snackbarDuration: const Duration(seconds: 3),
          position: DelightSnackbarPosition.top,
          builder: (context) => ToastCard(
            leading: Icon(
              LucideIcons.circleCheck,
              size: 28,
              color: AppColors.success,
            ),
            title: Text(
              'Report submitted successfully',
              style: HomifyTypography.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            color: Colors.white,
          ),
        ).show(context);
        context.pop();
      },
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return ReportTypeStep(
          selectedType: _selectedType,
          onTypeSelected: (type) {
            setState(() {
              _selectedType = type;
            });
          },
        );
      case 1:
        return ReportDetailsStep(
          titleController: _titleController,
          descriptionController: _descriptionController,
          formKey: _formKey,
        );
      case 2:
        return ReportReviewStep(
          selectedType: _selectedType,
          title: _titleController.text,
          description: _descriptionController.text,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report Issue',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          StepProgressBar(
            totalSteps: 3,
            currentStep: _currentStep,
            isSubmitting: _isSubmitting,
          ),
          Expanded(
            child: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 500),
              reverse: _isReverse,
              transitionBuilder:
                  (
                    Widget child,
                    Animation<double> primaryAnimation,
                    Animation<double> secondaryAnimation,
                  ) {
                    return SharedAxisTransition(
                      animation: primaryAnimation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.horizontal,
                      fillColor: Colors.transparent,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: child,
                      ),
                    );
                  },
              child: KeyedSubtree(
                key: ValueKey(_currentStep),
                child: _buildStepContent(),
              ),
            ),
          ),
          if (!isKeyboardOpen)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : _prevStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSubmitting
                          ? null
                          : (_currentStep == 2 ? _submitReport : _nextStep),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _currentStep == 2
                            ? (_isSubmitting ? 'Submitting...' : 'Submit')
                            : 'Next',
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
