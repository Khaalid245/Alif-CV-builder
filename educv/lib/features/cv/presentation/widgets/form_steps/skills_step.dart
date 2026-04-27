import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/app_input.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../providers/cv_provider.dart';
import '../../../data/models/cv_models.dart';
import '../add_item_button.dart';
import '../step_bottom_sheet.dart';
import '../level_selector.dart';

class SkillsStep extends ConsumerWidget {
  const SkillsStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsAsync = ref.watch(skillsProvider);
    
    return skillsAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
      data: (skills) => SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (skills.isEmpty)
              EmptyState(
                icon: Icons.flash_on,
                title: 'No skills added',
                subtitle: 'Add technical skills, soft skills and tools',
                actionLabel: 'Add Skill',
                onAction: () => _showSkillSheet(context, ref),
              )
            else ...[
              ..._buildSkillSections(skills, context, ref),
              
              SizedBox(height: AppSpacing.md),
            ],
            
            AddItemButton(
              label: 'Add Skill',
              onTap: () => _showSkillSheet(context, ref),
            ),
            
            SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSkillSections(List<SkillModel> skills, BuildContext context, WidgetRef ref) {
    final groupedSkills = <String, List<SkillModel>>{};
    
    for (final skill in skills) {
      groupedSkills.putIfAbsent(skill.category, () => []).add(skill);
    }
    
    final sections = <Widget>[];
    
    for (final entry in groupedSkills.entries) {
      sections.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getCategoryDisplayName(entry.key),
              style: AppTypography.label.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: entry.value.map((skill) => _SkillChip(
                skill: skill,
                onEdit: () => _showSkillSheet(context, ref, skill: skill),
                onDelete: () => _showDeleteConfirmation(context, ref, skill),
              )).toList(),
            ),
            
            SizedBox(height: AppSpacing.lg),
          ],
        ),
      );
    }
    
    return sections;
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toLowerCase()) {
      case 'technical':
        return 'Technical Skills';
      case 'soft':
        return 'Soft Skills';
      case 'language':
        return 'Language Skills';
      case 'other':
        return 'Other Skills';
      default:
        return category;
    }
  }

  void _showSkillSheet(BuildContext context, WidgetRef ref, {SkillModel? skill}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SkillBottomSheet(
        skill: skill,
        onSave: (data) async {
          try {
            if (skill != null) {
              await ref.read(skillsProvider.notifier).updateSkill(skill.id, data);
            } else {
              await ref.read(skillsProvider.notifier).add(data);
            }
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error saving skill: $e')),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, SkillModel skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Skill'),
        content: Text('This will permanently remove this skill.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(skillsProvider.notifier).delete(skill.id);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting skill: $e')),
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

class _SkillChip extends StatelessWidget {
  final SkillModel skill;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SkillChip({
    required this.skill,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill.name,
            style: AppTypography.caption.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            '• ${skill.level}',
            style: AppTypography.caption.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onEdit,
            child: Icon(
              Icons.edit,
              size: 12,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.close,
              size: 12,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillBottomSheet extends StatefulWidget {
  final SkillModel? skill;
  final Function(Map<String, dynamic>) onSave;

  const _SkillBottomSheet({
    this.skill,
    required this.onSave,
  });

  @override
  State<_SkillBottomSheet> createState() => _SkillBottomSheetState();
}

class _SkillBottomSheetState extends State<_SkillBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quickAddController = TextEditingController();
  
  String _selectedCategory = 'technical';
  String _selectedLevel = 'beginner';
  bool _isLoading = false;

  final Map<String, String> _categories = {
    'technical': 'Technical',
    'soft': 'Soft Skill',
    'language': 'Language',
    'other': 'Other',
  };

  final Map<String, String> _levels = {
    'beginner': 'Beginner',
    'intermediate': 'Intermediate',
    'advanced': 'Advanced',
    'expert': 'Expert',
  };

  @override
  void initState() {
    super.initState();
    if (widget.skill != null) {
      final skill = widget.skill!;
      _nameController.text = skill.name;
      _selectedCategory = skill.category;
      _selectedLevel = skill.level;
    }
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final data = {
      'name': _nameController.text.trim(),
      'category': _selectedCategory,
      'level': _selectedLevel,
    };
    
    await widget.onSave(data);
    setState(() => _isLoading = false);
  }

  void _quickAdd() async {
    if (_quickAddController.text.trim().isEmpty) return;
    
    final data = {
      'name': _quickAddController.text.trim(),
      'category': _selectedCategory,
      'level': _selectedLevel,
    };
    
    await widget.onSave(data);
    _quickAddController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return StepBottomSheet(
      title: widget.skill != null ? 'Edit Skill' : 'Add Skill',
      isLoading: _isLoading,
      onSave: _save,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppInput(
              label: 'Skill Name',
              hint: 'e.g. Python, Leadership, Figma',
              controller: _nameController,
              isRequired: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Skill name is required';
                }
                return null;
              },
            ),
            
            SizedBox(height: AppSpacing.md),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: AppTypography.label,
                ),
                SizedBox(height: AppSpacing.sm),
                
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  items: _categories.entries.map((category) {
                    return DropdownMenuItem(
                      value: category.key,
                      child: Text(category.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
              ],
            ),
            
            SizedBox(height: AppSpacing.md),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level',
                  style: AppTypography.label,
                ),
                SizedBox(height: AppSpacing.sm),
                
                LevelSelector(
                  options: _levels.values.toList(),
                  selected: _levels[_selectedLevel] ?? 'Beginner',
                  onChanged: (level) {
                    setState(() {
                      _selectedLevel = _levels.entries
                          .firstWhere((entry) => entry.value == level)
                          .key;
                    });
                  },
                ),
              ],
            ),
            
            if (widget.skill == null) ...[
              SizedBox(height: AppSpacing.xl),
              
              Text(
                'Add another skill quickly:',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              SizedBox(height: AppSpacing.sm),
              
              Row(
                children: [
                  Expanded(
                    child: AppInput(
                      label: 'Quick Add',
                      controller: _quickAddController,
                      hint: 'Skill name',
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: _quickAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    child: Text('Add'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quickAddController.dispose();
    super.dispose();
  }
}
