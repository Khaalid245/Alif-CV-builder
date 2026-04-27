import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
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

class ProjectsStep extends ConsumerWidget {
  const ProjectsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    
    return projectsAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
      data: (projects) => SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            if (projects.isEmpty)
              EmptyState(
                icon: Icons.code,
                title: 'No projects added',
                subtitle: 'Showcase your personal and academic projects',
                actionLabel: 'Add Project',
                onAction: () => _showProjectSheet(context, ref),
              )
            else ...[
              ...projects.map((project) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: _ProjectTile(
                  project: project,
                  onEdit: () => _showProjectSheet(context, ref, project: project),
                  onDelete: () => _showDeleteConfirmation(context, ref, project),
                ),
              )),
              
              SizedBox(height: AppSpacing.md),
            ],
            
            AddItemButton(
              label: 'Add Project',
              onTap: () => _showProjectSheet(context, ref),
            ),
            
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  void _showProjectSheet(BuildContext context, WidgetRef ref, {ProjectModel? project}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProjectBottomSheet(
        project: project,
        onSave: (data) async {
          try {
            if (project != null) {
              await ref.read(projectsProvider.notifier).updateProject(project.id, data);
            } else {
              await ref.read(projectsProvider.notifier).add(data);
            }
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving project: $e')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, ProjectModel project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Project'),
        content: Text('This will permanently remove this project.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(projectsProvider.notifier).delete(project.id);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting project: $e')),
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

class _ProjectTile extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectTile({
    required this.project,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String? _getDateRange() {
    if (project.startDate == null) return null;
    
    final start = _formatDate(project.startDate!);
    final end = project.endDate != null ? _formatDate(project.endDate!) : 'Ongoing';
    
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: AppTypography.h3,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: onEdit,
                    child: Icon(
                      Icons.edit,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.delete,
                      size: 20,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.xs),
          
          Text(
            project.description,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          if (project.link != null) ...[
            SizedBox(height: AppSpacing.xs),
            GestureDetector(
              onTap: () async {
                final uri = Uri.parse(project.link!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.link,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'View Project',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          if (_getDateRange() != null) ...[
            SizedBox(height: AppSpacing.xs),
            Text(
              _getDateRange()!,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProjectBottomSheet extends StatefulWidget {
  final ProjectModel? project;
  final Function(Map<String, dynamic>) onSave;

  const _ProjectBottomSheet({
    this.project,
    required this.onSave,
  });

  @override
  State<_ProjectBottomSheet> createState() => _ProjectBottomSheetState();
}

class _ProjectBottomSheetState extends State<_ProjectBottomSheet> {
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
      final project = widget.project!;
      _titleController.text = project.title;
      _descriptionController.text = project.description;
      _linkController.text = project.link ?? '';
      _startDate = project.startDate;
      _endDate = project.endDate;
      _isOngoing = project.endDate == null && project.startDate != null;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final data = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'link': _linkController.text.trim(),
      'start_date': _startDate?.toIso8601String().split('T')[0],
      'end_date': _isOngoing ? null : _endDate?.toIso8601String().split('T')[0],
    };
    
    await widget.onSave(data);
    setState(() => _isLoading = false);
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlPattern.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return StepBottomSheet(
      title: widget.project != null ? 'Edit Project' : 'Add Project',
      isLoading: _isLoading,
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppInput(
              label: 'Project Title',
              hint: 'e.g. Student Portal App',
              controller: _titleController,
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Project title is required';
                }
                return null;
              },
            ),
            
            SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Description',
              hint: 'What did you build? What problem did it solve? What did you learn?',
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
            
            SizedBox(height: AppSpacing.md),
            
            AppInput(
              label: 'Project Link (Optional)',
              hint: 'github.com/you/project or yourapp.com',
              controller: _linkController,
              keyboardType: TextInputType.url,
              prefixIcon: Icon(Icons.link, color: AppColors.primary),
              validator: _validateUrl,
            ),
            
            SizedBox(height: AppSpacing.md),
            
            MonthYearPicker(
              label: 'Start Date (Optional)',
              value: _startDate,
              onChanged: (date) {
                setState(() {
                  _startDate = date;
                });
              },
            ),
            
            SizedBox(height: AppSpacing.md),
            
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
              SizedBox(height: AppSpacing.md),
              
              MonthYearPicker(
                label: 'End Date (Optional)',
                value: _endDate,
                onChanged: (date) {
                  setState(() {
                    _endDate = date;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }
}
