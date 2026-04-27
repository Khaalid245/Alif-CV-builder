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

class EducationStep extends ConsumerWidget {
  const EducationStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final educationAsync = ref.watch(educationProvider);
    
    return educationAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
      data: (education) => SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            if (education.isEmpty)
              EmptyState(
                icon: Icons.school,
                title: 'No education added',
                subtitle: 'Add your degrees and academic qualifications',
                actionLabel: 'Add Education',
                onAction: () => _showEducationSheet(context, ref),
              )
            else ...[
              ...education.map((edu) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: CVSectionTile(
                  title: '${edu.degree} in ${edu.fieldOfStudy}',
                  subtitle: edu.institution,
                  trailing: '${edu.startYear} – ${edu.isCurrent ? 'Present' : edu.endYear}',
                  badge: edu.isCurrent ? _CurrentBadge() : null,
                  onEdit: () => _showEducationSheet(context, ref, education: edu),
                  onDelete: () => _showDeleteConfirmation(context, ref, edu),
                ),
              )),
              
              SizedBox(height: AppSpacing.md),
            ],
            
            AddItemButton(
              label: 'Add Education',
              onTap: () => _showEducationSheet(context, ref),
            ),
            
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _showEducationSheet(BuildContext context, WidgetRef ref, {EducationModel? education}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EducationBottomSheet(
        education: education,
        onSave: (data) async {
          try {
            if (education != null) {
              await ref.read(educationProvider.notifier).updateEducation(education.id, data);
            } else {
              await ref.read(educationProvider.notifier).add(data);
            }
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving education: $e')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, EducationModel education) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Education'),
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
                await ref.read(educationProvider.notifier).delete(education.id);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting education: $e')),
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

class _EducationBottomSheet extends StatefulWidget {
  final EducationModel? education;
  final Function(Map<String, dynamic>) onSave;

  const _EducationBottomSheet({
    this.education,
    required this.onSave,
  });

  @override
  State<_EducationBottomSheet> createState() => _EducationBottomSheetState();
}

class _EducationBottomSheetState extends State<_EducationBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _degreeController = TextEditingController();
  final _fieldController = TextEditingController();
  final _institutionController = TextEditingController();
  final _startYearController = TextEditingController();
  final _endYearController = TextEditingController();
  final _gpaController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  bool _isCurrent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.education != null) {
      final edu = widget.education!;
      _degreeController.text = edu.degree;
      _fieldController.text = edu.fieldOfStudy;
      _institutionController.text = edu.institution;
      _startYearController.text = edu.startYear.toString();
      _endYearController.text = edu.endYear?.toString() ?? '';
      _gpaController.text = edu.gpa?.toString() ?? '';
      _descriptionController.text = edu.description ?? '';
      _isCurrent = edu.isCurrent;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final data = {
      'degree': _degreeController.text.trim(),
      'field_of_study': _fieldController.text.trim(),
      'institution': _institutionController.text.trim(),
      'start_year': int.parse(_startYearController.text.trim()),
      'end_year': _isCurrent ? null : int.tryParse(_endYearController.text.trim()),
      'is_current': _isCurrent,
      'gpa': _gpaController.text.isNotEmpty ? double.tryParse(_gpaController.text.trim()) : null,
      'description': _descriptionController.text.trim(),
    };
    
    await widget.onSave(data);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return StepBottomSheet(
      title: widget.education != null ? 'Edit Education' : 'Add Education',
      isLoading: _isLoading,
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppInput(
              label: 'Degree Type',
              hint: 'e.g. Bachelor of Science',
              controller: _degreeController,
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Degree is required';
                }
                return null;
              },
            ),
            
            SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Field of Study',
              hint: 'e.g. Computer Science',
              controller: _fieldController,
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Field of study is required';
                }
                return null;
              },
            ),
            
            SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'University / Institution',
              hint: 'e.g. MIT',
              controller: _institutionController,
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Institution is required';
                }
                return null;
              },
            ),
            
            SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Start Year',
              hint: 'e.g. 2020',
              controller: _startYearController,
              keyboardType: TextInputType.number,
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Start year is required';
                }
                final year = int.tryParse(value.trim());
                if (year == null || year < 1950 || year > DateTime.now().year + 10) {
                  return 'Please enter a valid year';
                }
                return null;
              },
            ),
            
            SizedBox(height: AppSpacing.md),
            
            Row(
              children: [
                Expanded(
                  child: Text(
                    'I am currently studying here',
                    style: AppTypography.body,
                  ),
                ),
                Switch.adaptive(
                  value: _isCurrent,
                  onChanged: (value) {
                    setState(() {
                      _isCurrent = value;
                      if (value) {
                        _endYearController.clear();
                      }
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            
            if (!_isCurrent) ...[
              SizedBox(height: AppSpacing.md),
              
              AppInput(
                label: 'Graduation Year',
                hint: 'e.g. 2024',
                controller: _endYearController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (!_isCurrent && (value == null || value.trim().isEmpty)) {
                    return 'Graduation year is required';
                  }
                  if (value != null && value.isNotEmpty) {
                    final year = int.tryParse(value.trim());
                    if (year == null || year < 1950 || year > DateTime.now().year + 10) {
                      return 'Please enter a valid year';
                    }
                  }
                  return null;
                },
              ),
            ],
            
            SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'GPA (Optional)',
              hint: 'e.g. 3.8',
              controller: _gpaController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            
            SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Additional Info (Optional)',
              hint: 'Relevant coursework, honors, activities...',
              controller: _descriptionController,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _degreeController.dispose();
    _fieldController.dispose();
    _institutionController.dispose();
    _startYearController.dispose();
    _endYearController.dispose();
    _gpaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
