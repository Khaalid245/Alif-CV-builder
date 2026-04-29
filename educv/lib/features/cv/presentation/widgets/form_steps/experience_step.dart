import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

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
import '../month_year_picker.dart';
import '../step_bottom_sheet.dart';

class ExperienceStep extends ConsumerStatefulWidget {
  const ExperienceStep({super.key});

  @override
  ConsumerState<ExperienceStep> createState() => _ExperienceStepState();
}

class _ExperienceStepState extends ConsumerState<ExperienceStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(experienceProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final experienceState = ref.watch(experienceProvider);

    return experienceState.when(
      data: (experienceList) => _buildContent(experienceList),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Error loading experience: $error',
          style: AppTypography.body.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildContent(List<ExperienceModel> experienceList) {
    if (experienceList.isEmpty) {
      return EmptyState(
        icon: LucideIcons.briefcase,
        title: 'No experience added',
        subtitle: 'Add internships, jobs or volunteer work',
        actionText: 'Add Experience',
        onAction: () => _showExperienceSheet(),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: experienceList.length,
            itemBuilder: (context, index) {
              final experience = experienceList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildExperienceTile(experience),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AddItemButton(
            text: 'Add Experience',
            onTap: () => _showExperienceSheet(),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceTile(ExperienceModel experience) {
    final startDate = DateFormat('MMM yyyy').format(experience.startDate);
    final endDate = experience.isCurrent 
        ? 'Present'
        : experience.endDate != null 
            ? DateFormat('MMM yyyy').format(experience.endDate!)
            : 'Present';
    
    final dateText = '$startDate – $endDate';

    return CVSectionTile(
      title: '${experience.jobTitle} at ${experience.company}',
      subtitle: experience.location.isNotEmpty ? experience.location : experience.company,
      trailing: dateText,
      badge: experience.isCurrent ? _buildCurrentBadge() : null,
      onEdit: () => _showExperienceSheet(experience: experience),
      onDelete: () => _showDeleteConfirmation(experience),
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

  void _showExperienceSheet({ExperienceModel? experience}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExperienceBottomSheet(experience: experience),
    );
  }

  void _showDeleteConfirmation(ExperienceModel experience) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Experience', style: AppTypography.h3),
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
              ref.read(experienceProvider.notifier).delete(experience.id);
              SnackbarHelper.showSuccess(context, 'Experience removed');
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

class _ExperienceBottomSheet extends ConsumerStatefulWidget {
  final ExperienceModel? experience;

  const _ExperienceBottomSheet({this.experience});

  @override
  ConsumerState<_ExperienceBottomSheet> createState() => _ExperienceBottomSheetState();
}

class _ExperienceBottomSheetState extends ConsumerState<_ExperienceBottomSheet> {
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
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final experience = widget.experience!;
    _jobTitleController.text = experience.jobTitle;
    _companyController.text = experience.company;
    _locationController.text = experience.location;
    _descriptionController.text = experience.description;
    _startDate = experience.startDate;
    _endDate = experience.endDate;
    _isCurrent = experience.isCurrent;
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepBottomSheet(
      title: widget.experience == null ? 'Add Experience' : 'Edit Experience',
      isLoading: _isLoading,
      onSave: _saveExperience,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppInput(
              label: 'Job Title',
              hint: 'e.g. Software Engineer Intern',
              controller: _jobTitleController,
              validator: (value) => value?.isEmpty == true ? 'Job title is required' : null,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Company',
              hint: 'e.g. Google',
              controller: _companyController,
              validator: (value) => value?.isEmpty == true ? 'Company is required' : null,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Location (Optional)',
              hint: 'e.g. San Francisco, CA or Remote',
              controller: _locationController,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            MonthYearPicker(
              label: 'Start Date',
              selectedDate: _startDate,
              onChanged: (date) => setState(() => _startDate = date),
              validator: (value) => _startDate == null ? 'Start date is required' : null,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Currently Working Toggle
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
              const SizedBox(height: AppSpacing.md),
              MonthYearPicker(
                label: 'End Date',
                selectedDate: _endDate,
                onChanged: (date) => setState(() => _endDate = date),
                validator: (value) => !_isCurrent && _endDate == null ? 'End date is required' : null,
              ),
            ],
            
            const SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'What did you do?',
              hint: 'Describe your responsibilities, achievements and impact...',
              controller: _descriptionController,
              maxLines: 5,
              maxLength: 600,
              validator: (value) => value?.isEmpty == true ? 'Description is required' : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveExperience() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) return;
    if (!_isCurrent && _endDate == null) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'job_title': _jobTitleController.text.trim(),
        'company': _companyController.text.trim(),
        'location': _locationController.text.trim(),
        'start_date': _startDate!.toIso8601String().split('T')[0],
        'end_date': _isCurrent ? null : _endDate?.toIso8601String().split('T')[0],
        'is_current': _isCurrent,
        'description': _descriptionController.text.trim(),
      };

      if (widget.experience == null) {
        await ref.read(experienceProvider.notifier).add(data);
        SnackbarHelper.showSuccess(context, 'Experience added successfully');
      } else {
        await ref.read(experienceProvider.notifier).updateItem(widget.experience!.id, data);
        SnackbarHelper.showSuccess(context, 'Experience updated successfully');
      }

      Navigator.of(context).pop();
    } catch (e) {
      SnackbarHelper.showError(context, 'Failed to save experience');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
