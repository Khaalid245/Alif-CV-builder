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

class ProjectsStep extends ConsumerStatefulWidget {
  const ProjectsStep({super.key});

  @override
  ConsumerState<ProjectsStep> createState() => _ProjectsStepState();
}

class _ProjectsStepState extends ConsumerState<ProjectsStep> {
  @override
  void initState() {
    super.initState();
    // Data is pre-populated from cvProfileProvider.fetch() — no separate API call needed
  }

  @override
  Widget build(BuildContext context) {
    final projectsState = ref.watch(projectsProvider);

    return projectsState.when(
      data: (projectsList) => _buildContent(projectsList),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Error loading projects: $error',
          style: AppTypography.body.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildContent(List<ProjectModel> projectsList) {
    if (projectsList.isEmpty) {
      return EmptyState(
        icon: LucideIcons.code2,
        title: 'No projects added',
        subtitle: 'Showcase your personal and academic projects',
        actionText: 'Add Project',
        onAction: () => _showProjectSheet(),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: projectsList.length,
            itemBuilder: (context, index) {
              final project = projectsList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildProjectTile(project),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AddItemButton(
            text: 'Add Project',
            onTap: () => _showProjectSheet(),
          ),
        ),
      ],
    );
  }

  Widget _buildProjectTile(ProjectModel project) {
    String? dateText;
    if (project.startDate != null) {
      final startDate = DateFormat('MMM yyyy').format(project.startDate!);
      final endDate = project.endDate != null 
          ? DateFormat('MMM yyyy').format(project.endDate!)
          : 'Ongoing';
      dateText = '$startDate – $endDate';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: CVSectionTile(
        title: project.title,
        subtitle: project.description.length > 100 
            ? '${project.description.substring(0, 100)}...'
            : project.description,
        trailing: dateText,
        onEdit: () => _showProjectSheet(project: project),
        onDelete: () => _showDeleteConfirmation(project),
      ),
    );
  }

  void _showProjectSheet({ProjectModel? project}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProjectBottomSheet(project: project),
    );
  }

  void _showDeleteConfirmation(ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Project', style: AppTypography.h3),
        content: Text(
          'This will permanently remove "${project.title}" from your projects.',
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
              ref.read(projectsProvider.notifier).delete(project.id);
              SnackbarHelper.showSuccess(context, 'Project removed');
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

class _ProjectBottomSheet extends ConsumerStatefulWidget {
  final ProjectModel? project;

  const _ProjectBottomSheet({this.project});

  @override
  ConsumerState<_ProjectBottomSheet> createState() => _ProjectBottomSheetState();
}

class _ProjectBottomSheetState extends ConsumerState<_ProjectBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOngoing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.project != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final project = widget.project!;
    _titleController.text = project.title;
    _descriptionController.text = project.description;
    _linkController.text = project.link;
    _startDate = project.startDate;
    _endDate = project.endDate;
    _isOngoing = project.endDate == null && project.startDate != null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepBottomSheet(
      title: widget.project == null ? 'Add Project' : 'Edit Project',
      isLoading: _isLoading,
      onSave: _saveProject,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppInput(
              label: 'Project Title',
              hint: 'e.g. Student Portal App',
              controller: _titleController,
              validator: (value) => value?.isEmpty == true ? 'Project title is required' : null,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Description',
              hint: 'What did you build? What problem did it solve? What did you learn?',
              controller: _descriptionController,
              maxLines: 5,
              maxLength: 600,
              validator: (value) => value?.isEmpty == true ? 'Description is required' : null,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Project Link (Optional)',
              hint: 'github.com/you/project or yourapp.com',
              controller: _linkController,
              keyboardType: TextInputType.url,
              prefixIcon: const Icon(
                LucideIcons.link,
                color: AppColors.textSecondary,
              ),
              validator: _validateUrl,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            MonthYearPicker(
              label: 'Start Date (Optional)',
              selectedDate: _startDate,
              onChanged: (date) => setState(() => _startDate = date),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Ongoing Project Toggle
            Row(
              children: [
                Expanded(
                  child: Text(
                    'This is an ongoing project',
                    style: AppTypography.body,
                  ),
                ),
                Switch.adaptive(
                  value: _isOngoing,
                  onChanged: (value) {
                    setState(() {
                      _isOngoing = value;
                      if (value) {
                        _endDate = null;
                      }
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            
            if (!_isOngoing) ...[
              const SizedBox(height: AppSpacing.md),
              MonthYearPicker(
                label: 'End Date (Optional)',
                selectedDate: _endDate,
                onChanged: (date) => setState(() => _endDate = date),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    
    String url = value;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    final urlPattern = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
    if (!RegExp(urlPattern).hasMatch(url)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String link = _linkController.text.trim();
      if (link.isNotEmpty && !link.startsWith('http://') && !link.startsWith('https://')) {
        link = 'https://$link';
      }

      final data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'link': link,
        'start_date': _startDate?.toIso8601String().split('T')[0],
        'end_date': _isOngoing ? null : _endDate?.toIso8601String().split('T')[0],
      };

      if (widget.project == null) {
        await ref.read(projectsProvider.notifier).add(data);
        if (!mounted) return;
        SnackbarHelper.showSuccess(context, 'Project added successfully');
      } else {
        await ref.read(projectsProvider.notifier).updateItem(widget.project!.id, data);
        if (!mounted) return;
        SnackbarHelper.showSuccess(context, 'Project updated successfully');
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.showError(context, 'Failed to save project');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
