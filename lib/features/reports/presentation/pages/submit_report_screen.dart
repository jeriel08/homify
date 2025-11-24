import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:homify/core/utils/uuid_generator.dart';
import 'package:homify/features/auth/presentation/providers/auth_providers.dart';
import 'package:homify/features/reports/domain/entities/report_entity.dart';
import 'package:homify/features/reports/presentation/providers/report_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a report type')),
      );
      return;
    }
    if (_currentStep == 1) {
      if (!_formKey.currentState!.validate()) return;
    }
    setState(() {
      _currentStep++;
    });
  }

  void _prevStep() {
    setState(() {
      _currentStep--;
    });
  }

  Future<void> _submitReport() async {
    setState(() {
      _isSubmitting = true;
    });

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to submit a report'),
        ),
      );
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

    setState(() {
      _isSubmitting = false;
    });

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: ${failure.message}'),
          ),
        );
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
        context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Issue'),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: _currentStep == 2 ? _submitReport : _nextStep,
        onStepCancel: _currentStep == 0 ? null : _prevStep,
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : details.onStepContinue,
                    child: Text(
                      _currentStep == 2
                          ? (_isSubmitting ? 'Submitting...' : 'Submit')
                          : 'Next',
                    ),
                  ),
                ),
                if (_currentStep > 0) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Type'),
            content: Column(
              children: ReportType.values.map((type) {
                return RadioListTile<ReportType>(
                  title: Text(type.name.toUpperCase()),
                  value: type,
                  groupValue: _selectedType,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                );
              }).toList(),
            ),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Details'),
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Brief summary of the issue',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Detailed description of the issue',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Review'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Type: ${_selectedType?.name.toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Title: ${_titleController.text}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(_descriptionController.text),
              ],
            ),
            isActive: _currentStep >= 2,
          ),
        ],
      ),
    );
  }
}
