import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/utils/snackbar_helper.dart';
import '../../../../../core/widgets/app_input.dart';
import '../../../data/models/cv_models.dart';
import '../../providers/cv_provider.dart';
import '../add_item_button.dart';
import '../cv_section_tile.dart';
import '../empty_state.dart';
import '../step_bottom_sheet.dart';

class EducationStep extends ConsumerStatefulWidget {
  const EducationStep({super.key});

  @override
  ConsumerState<EducationStep> createState() => _EducationStepState();
}

class _EducationStepState extends ConsumerState<EducationStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(educationProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final educationState = ref.watch(educationProvider);

    return educationState.when(
      data: (educationList) => _buildContent(educationList),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Error loading education: $error',
          style: AppTypography.body.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildContent(List<EducationModel> educationList) {
    if (educationList.isEmpty) {
      return EmptyState(
        icon: LucideIcons.graduationCap,
        title: 'No education added',
        subtitle: 'Add your degrees and academic qualifications',
        actionText: 'Add Education',
        onAction: () => _showEducationSheet(),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: educationList.length,
            itemBuilder: (context, index) {
              final education = educationList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildEducationTile(education),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AddItemButton(
            text: 'Add Education',
            onTap: () => _showEducationSheet(),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationTile(EducationModel education) {
    final yearText = education.isCurrent 
        ? '${education.startYear} – Present'
        : '${education.startYear} – ${education.endYear ?? 'Present'}';

    return CVSectionTile(
      title: '${education.degree} in ${education.fieldOfStudy}',
      subtitle: education.institution,
      trailing: yearText,
      badge: education.isCurrent ? _buildCurrentBadge() : null,
      onEdit: () => _showEducationSheet(education: education),
      onDelete: () => _showDeleteConfirmation(education),
    );
  }

  Widget _buildCurrentBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Current',
        style: AppTypography.caption.copyWith(
          color: AppColors.primary,
          fontSize: 10,
        ),
      ),
    );
  }

  void _showEducationSheet({EducationModel? education}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EducationBottomSheet(education: education),
    );
  }

  void _showDeleteConfirmation(EducationModel education) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Education', style: AppTypography.h3),
        content: Text(
          'This will permanently remove this entry.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Keep',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(educationProvider.notifier).delete(education.id);
              SnackbarHelper.showSuccess(context, 'Education removed');
            },
            child: Text(
              'Remove',
              style: AppTypography.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _EducationBottomSheet extends ConsumerStatefulWidget {
  final EducationModel? education;

  const _EducationBottomSheet({this.education});

  @override
  ConsumerState<_EducationBottomSheet> createState() => _EducationBottomSheetState();
}

class _EducationBottomSheetState extends ConsumerState<_EducationBottomSheet> {
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
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final education = widget.education!;
    _degreeController.text = education.degree;
    _fieldController.text = education.fieldOfStudy;
    _institutionController.text = education.institution;
    _startYearController.text = education.startYear.toString();
    _endYearController.text = education.endYear?.toString() ?? '';
    _gpaController.text = education.gpa?.toString() ?? '';
    _descriptionController.text = education.description;
    _isCurrent = education.isCurrent;
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

  @override
  Widget build(BuildContext context) {
    return StepBottomSheet(
      title: widget.education == null ? 'Add Education' : 'Edit Education',
      isLoading: _isLoading,
      onSave: _saveEducation,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppInput(
              label: 'Degree Type',
              hint: 'e.g. Bachelor of Science',
              controller: _degreeController,
              validator: (value) => value?.isEmpty == true ? 'Degree is required' : null,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Field of Study',
              hint: 'e.g. Computer Science',
              controller: _fieldController,
              validator: (value) => value?.isEmpty == true ? 'Field of study is required' : null,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'University / Institution',
              hint: 'e.g. MIT',
              controller: _institutionController,
              validator: (value) => value?.isEmpty == true ? 'Institution is required' : null,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Start Year',
              hint: 'e.g. 2020',
              controller: _startYearController,
              keyboardType: TextInputType.number,
              validator: _validateYear,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Currently Studying Toggle
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
              const SizedBox(height: AppSpacing.md),
              AppInput(
                label: 'Graduation Year',
                hint: 'e.g. 2024',
                controller: _endYearController,
                keyboardType: TextInputType.number,
                validator: _validateEndYear,
              ),
            ],
            
            const SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'GPA (Optional)',
              hint: 'e.g. 3.8',
              controller: _gpaController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: _validateGpa,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
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

  String? _validateYear(String? value) {
    if (value?.isEmpty == true) return 'Start year is required';
    
    final year = int.tryParse(value!);
    if (year == null) return 'Please enter a valid year';
    
    final currentYear = DateTime.now().year;
    if (year < 1950 || year > currentYear + 10) {
      return 'Please enter a year between 1950 and ${currentYear + 10}';
    }
    
    return null;
  }

  String? _validateEndYear(String? value) {
    if (_isCurrent) return null;
    if (value?.isEmpty == true) return 'End year is required';
    
    final year = int.tryParse(value!);
    if (year == null) return 'Please enter a valid year';
    
    final startYear = int.tryParse(_startYearController.text);
    if (startYear != null && year < startYear) {
      return 'End year must be after start year';
    }
    
    return null;
  }

  String? _validateGpa(String? value) {
    if (value?.isEmpty == true) return null;
    
    final gpa = double.tryParse(value!);
    if (gpa == null) return 'Please enter a valid GPA';
    
    if (gpa < 0 || gpa > 4.0) {
      return 'GPA must be between 0.0 and 4.0';
    }
    
    return null;
  }

  Future<void> _saveEducation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'degree': _degreeController.text.trim(),
        'field_of_study': _fieldController.text.trim(),
        'institution': _institutionController.text.trim(),
        'start_year': int.parse(_startYearController.text),
        'end_year': _isCurrent ? null : int.tryParse(_endYearController.text),
        'is_current': _isCurrent,
        'gpa': _gpaController.text.isNotEmpty ? double.tryParse(_gpaController.text) : null,
        'description': _descriptionController.text.trim(),
      };

      if (widget.education == null) {
        await ref.read(educationProvider.notifier).add(data);
        SnackbarHelper.showSuccess(context, 'Education added successfully');
      } else {
        await ref.read(educationProvider.notifier).updateItem(widget.education!.id, data);
        SnackbarHelper.showSuccess(context, 'Education updated successfully');
      }

      Navigator.of(context).pop();
    } catch (e) {
      SnackbarHelper.showError(context, 'Failed to save education');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
