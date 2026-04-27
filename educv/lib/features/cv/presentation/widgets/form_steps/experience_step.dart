import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_input.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../providers/cv_provider.dart';
import '../../../data/models/cv_models.dart';
import '../cv_section_tile.dart';
import '../add_item_button.dart';
import '../step_bottom_sheet.dart';
import '../month_year_picker.dart';

class ExperienceStep extends ConsumerWidget {
  const ExperienceStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final experienceAsync = ref.watch(experienceProvider);
    
    return experienceAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
      data: (experience) => SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            if (experience.isEmpty)
              EmptyState(
                icon: Icons.work,
                title: 'No experience added',
                subtitle: 'Add internships, jobs or volunteer work',
                actionLabel: 'Add Experience',
                onAction: () => _showExperienceSheet(context, ref),
              )
            else ...[
              ...experience.map((exp) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: CVSectionTile(
                  title: '${exp.jobTitle} at ${exp.company}',
                  subtitle: exp.location,
                  trailing: '${_formatDate(exp.startDate)} – ${exp.isCurrent ? 'Present' : _formatDate(exp.endDate!)}',
                  badge: exp.isCurrent ? _CurrentBadge() : null,
                  onEdit: () => _showExperienceSheet(context, ref, experience: exp),
                  onDelete: () => _showDeleteConfirmation(context, ref, exp),
                ),
              )),
              
              SizedBox(height: AppSpacing.md),
            ],
            
            AddItemButton(
              label: 'Add Experience',
              onTap: () => _showExperienceSheet(context, ref),
            ),
            
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showExperienceSheet(BuildContext context, WidgetRef ref, {ExperienceModel? experience}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExperienceBottomSheet(
        experience: experience,
        onSave: (data) async {
          try {
            if (experience != null) {
              await ref.read(experienceProvider.notifier).updateExperience(experience.id, data);
            } else {
              await ref.read(experienceProvider.notifier).add(data);
            }
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving experience: $e')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, ExperienceModel experience) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Experience'),
        content: Text('This will permanently remove this entry.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(experienceProvider.notifier).delete(experience.id);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting experience: $e')),
                );
              }
            },
            child: Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Current',
        style: AppTypography.caption.copyWith(
          color: AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ExperienceBottomSheet extends StatefulWidget {
  final ExperienceModel? experience;
  final Function(Map<String, dynamic>) onSave;

  const _ExperienceBottomSheet({
    this.experience,
    required this.onSave,
  });

  @override
  State<_ExperienceBottomSheet> createState() => _ExperienceBottomSheetState();
}

class _ExperienceBottomSheetState extends State<_ExperienceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.experience != null) {
      final exp = widget.experience!;
      _jobTitleController.text = exp.jobTitle;
      _companyController.text = exp.company;
      _locationController.text = exp.location ?? '';
      _descriptionController.text = exp.description;
      _startDate = exp.startDate;
      _endDate = exp.endDate;
      _isCurrent = exp.isCurrent;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a start date')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    final data = {
      'job_title': _jobTitleController.text.trim(),
      'company': _companyController.text.trim(),
      'location': _locationController.text.trim(),
      'start_date': _startDate!.toIso8601String().split('T')[0],
      'end_date': _isCurrent ? null : _endDate?.toIso8601String().split('T')[0],
      'is_current': _isCurrent,
      'description': _descriptionController.text.trim(),
    };
    
    await widget.onSave(data);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return StepBottomSheet(
      title: widget.experience != null ? 'Edit Experience' : 'Add Experience',
      isLoading: _isLoading,
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppInput(
              label: 'Job Title',
              hint: 'e.g. Software Engineer Intern',
              controller: _jobTitleController,
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Job title is required';
                }
                return null;
              },
            ),
            
            SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Company',
              hint: 'e.g. Google',
              controller: _companyController,
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Company is required';
                }
                return null;
              },
            ),
            
            SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Location (Optional)',
              hint: 'e.g. San Francisco, CA or Remote',
              controller: _locationController,
            ),
            
            SizedBox(height: AppSpacing.md),
            
            MonthYearPicker(
              label: 'Start Date',
              value: _startDate,
              onChanged: (date) {
                setState(() {
                  _startDate = date;
                });
              },
              isRequired: true,
            ),
            
            SizedBox(height: AppSpacing.md),
            
            Row(
              children: [
                Expanded(
                  child: Text(
                    'I am currently working here',
                    style: AppTypography.body,
                  ),
                ),
                Switch.adaptive(
                  value: _isCurrent,
                  onChanged: (value) {
                    setState(() {
                      _isCurrent = value;
                      if (value) {
                        _endDate = null;
                      }
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            
            if (!_isCurrent) ...[
              SizedBox(height: AppSpacing.md),
              
              MonthYearPicker(
                label: 'End Date',
                value: _endDate,
                onChanged: (date) {
                  setState(() {
                    _endDate = date;
                  });
                },
                isRequired: !_isCurrent,
              ),
            ],
            
            SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'What did you do?',
              hint: 'Describe your responsibilities, achievements and impact...',
              controller: _descriptionController,
              maxLines: 5,
              maxLength: 600,
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Description is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
