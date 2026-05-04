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
import '../empty_state.dart';
import '../level_selector.dart';
import '../step_bottom_sheet.dart';

class SkillsStep extends ConsumerStatefulWidget {
  const SkillsStep({super.key});

  @override
  ConsumerState<SkillsStep> createState() => _SkillsStepState();
}

class _SkillsStepState extends ConsumerState<SkillsStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(skillsProvider.notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final skillsState = ref.watch(skillsProvider);

    return skillsState.when(
      data: (skillsList) => _buildContent(skillsList),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Error loading skills: $error',
          style: AppTypography.body.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildContent(List<SkillModel> skillsList) {
    if (skillsList.isEmpty) {
      return EmptyState(
        icon: LucideIcons.zap,
        title: 'No skills added',
        subtitle: 'Add technical skills, soft skills and tools',
        actionText: 'Add Skill',
        onAction: () => _showSkillSheet(),
      );
    }

    // Group skills by category
    final groupedSkills = <String, List<SkillModel>>{};
    for (final skill in skillsList) {
      groupedSkills.putIfAbsent(skill.category, () => []).add(skill);
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...groupedSkills.entries.map((entry) => 
                  _buildSkillCategory(entry.key, entry.value)
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AddItemButton(
            text: 'Add Skill',
            onTap: () => _showSkillSheet(),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillCategory(String category, List<SkillModel> skills) {
    final categoryName = _getCategoryDisplayName(category);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryName,
          style: AppTypography.label.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: skills.map((skill) => _buildSkillChip(skill)).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  Widget _buildSkillChip(SkillModel skill) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surface,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            skill.name,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '• ${_getLevelDisplayName(skill.level)}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: () => _showSkillSheet(skill: skill),
            child: Icon(
              LucideIcons.edit,
              size: 12,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _showDeleteConfirmation(skill),
            child: Icon(
              LucideIcons.x,
              size: 12,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'technical':
        return 'Technical Skills';
      case 'soft':
        return 'Soft Skills';
      case 'language':
        return 'Language Skills';
      case 'other':
        return 'Other Skills';
      default:
        return 'Skills';
    }
  }

  String _getLevelDisplayName(String level) {
    switch (level) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      case 'expert':
        return 'Expert';
      default:
        return 'Intermediate';
    }
  }

  void _showSkillSheet({SkillModel? skill}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SkillBottomSheet(skill: skill),
    );
  }

  void _showDeleteConfirmation(SkillModel skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Skill', style: AppTypography.h3),
        content: Text(
          'This will permanently remove "${skill.name}" from your skills.',
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
              ref.read(skillsProvider.notifier).delete(skill.id);
              SnackbarHelper.showSuccess(context, 'Skill removed');
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

class _SkillBottomSheet extends ConsumerStatefulWidget {
  final SkillModel? skill;

  const _SkillBottomSheet({this.skill});

  @override
  ConsumerState<_SkillBottomSheet> createState() => _SkillBottomSheetState();
}

class _SkillBottomSheetState extends ConsumerState<_SkillBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quickAddController = TextEditingController();

  String _selectedCategory = 'technical';
  String _selectedLevel = 'intermediate';
  bool _isLoading = false;

  final List<String> _categories = ['technical', 'soft', 'language', 'other'];
  final List<String> _levels = ['beginner', 'intermediate', 'advanced', 'expert'];

  @override
  void initState() {
    super.initState();
    if (widget.skill != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final skill = widget.skill!;
    _nameController.text = skill.name;
    _selectedCategory = skill.category;
    _selectedLevel = skill.level;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quickAddController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepBottomSheet(
      title: widget.skill == null ? 'Add Skill' : 'Edit Skill',
      isLoading: _isLoading,
      onSave: _saveSkill,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            AppInput(
              label: 'Skill Name',
              hint: 'e.g. Python, Leadership, Figma',
              controller: _nameController,
              validator: (value) => value?.isEmpty == true ? 'Skill name is required' : null,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Category Dropdown
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: AppTypography.label,
                ),
                const SizedBox(height: AppSpacing.xs),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(_getCategoryDisplayName(category)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategory = value!);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Level Selector
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level',
                  style: AppTypography.label,
                ),
                const SizedBox(height: AppSpacing.xs),
                LevelSelector(
                  options: _levels.map((level) => _getLevelDisplayName(level)).toList(),
                  selected: _getLevelDisplayName(_selectedLevel),
                  onChanged: (displayName) {
                    final level = _levels.firstWhere(
                      (l) => _getLevelDisplayName(l) == displayName,
                    );
                    setState(() => _selectedLevel = level);
                  },
                ),
              ],
            ),
            
            if (widget.skill == null) ...[
              const SizedBox(height: AppSpacing.lg),
              
              // Quick Add Section
              Text(
                'Add another skill quickly:',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: AppInput(
                      label: 'Quick Add',
                      hint: 'Skill name',
                      controller: _quickAddController,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  ElevatedButton(
                    onPressed: _quickAddSkill,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    child: Text('Add', style: AppTypography.button),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'technical':
        return 'Technical';
      case 'soft':
        return 'Soft Skill';
      case 'language':
        return 'Language';
      case 'other':
        return 'Other';
      default:
        return 'Technical';
    }
  }

  String _getLevelDisplayName(String level) {
    switch (level) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      case 'expert':
        return 'Expert';
      default:
        return 'Intermediate';
    }
  }

  Future<void> _quickAddSkill() async {
    final skillName = _quickAddController.text.trim();
    if (skillName.isEmpty) return;

    try {
      final data = {
        'name': skillName,
        'category': _selectedCategory,
        'level': _selectedLevel,
      };

      await ref.read(skillsProvider.notifier).add(data);
      _quickAddController.clear();
      SnackbarHelper.showSuccess(context, 'Skill added');
    } catch (e) {
      SnackbarHelper.showError(context, 'Failed to add skill');
    }
  }

  Future<void> _saveSkill() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final data = {
        'name': _nameController.text.trim(),
        'category': _selectedCategory,
        'level': _selectedLevel,
      };

      if (widget.skill == null) {
        await ref.read(skillsProvider.notifier).add(data);
        SnackbarHelper.showSuccess(context, 'Skill added successfully');
      } else {
        await ref.read(skillsProvider.notifier).updateItem(widget.skill!.id, data);
        SnackbarHelper.showSuccess(context, 'Skill updated successfully');
      }

      Navigator.of(context).pop();
    } catch (e) {
      SnackbarHelper.showError(context, 'Failed to save skill');
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
