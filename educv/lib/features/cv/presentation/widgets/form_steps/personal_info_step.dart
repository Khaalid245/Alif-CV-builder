import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/app_input.dart';
import '../../providers/cv_provider.dart';
import '../section_divider.dart';

class PersonalInfoStep extends ConsumerStatefulWidget {
  const PersonalInfoStep({super.key});

  @override
  ConsumerState<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends ConsumerState<PersonalInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _summaryController = TextEditingController();

  File? _selectedPhoto;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _portfolioController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  void _loadExistingData() {
    final profile = ref.read(cvProfileProvider).value;
    if (profile != null) {
      _phoneController.text = profile.phone;
      _cityController.text = profile.city;
      _countryController.text = profile.country;
      _linkedinController.text = profile.linkedin;
      _githubController.text = profile.github;
      _portfolioController.text = profile.portfolio;
      _summaryController.text = profile.summary;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mock current user since currentUserProvider is not available
    final mockUser = {'fullName': 'John Doe'};
    final cvProfile = ref.watch(cvProfileProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Profile Photo Section
            _buildProfilePhotoSection(cvProfile.value?.photoUrl),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Basic Information
            const SectionDivider(label: 'Basic Information'),
            const SizedBox(height: AppSpacing.lg),
            
            // Full Name (Read-only)
            AppInput(
              label: 'Full Name',
              hint: 'Your full name',
              controller: TextEditingController(text: mockUser['fullName'] ?? ''),
              enabled: false,
              suffixIcon: const Icon(
                LucideIcons.lock,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'To change your name contact admin',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Phone Number
            AppInput(
              label: 'Phone Number',
              hint: '+1 234 567 8900',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // City
            AppInput(
              label: 'City',
              hint: 'e.g. New York',
              controller: _cityController,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Country
            AppInput(
              label: 'Country',
              hint: 'e.g. United States',
              controller: _countryController,
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Online Presence
            const SectionDivider(label: 'Online Presence'),
            const SizedBox(height: AppSpacing.lg),
            
            // LinkedIn
            AppInput(
              label: 'LinkedIn Profile',
              hint: 'linkedin.com/in/yourname',
              controller: _linkedinController,
              keyboardType: TextInputType.url,
              prefixIcon: const Icon(
                LucideIcons.linkedin,
                color: AppColors.textSecondary,
              ),
              validator: _validateUrl,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // GitHub
            AppInput(
              label: 'GitHub Profile',
              hint: 'github.com/yourname',
              controller: _githubController,
              keyboardType: TextInputType.url,
              prefixIcon: const Icon(
                LucideIcons.github,
                color: AppColors.textSecondary,
              ),
              validator: _validateUrl,
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Portfolio
            AppInput(
              label: 'Portfolio Website',
              hint: 'yourwebsite.com',
              controller: _portfolioController,
              keyboardType: TextInputType.url,
              prefixIcon: const Icon(
                LucideIcons.link,
                color: AppColors.textSecondary,
              ),
              validator: _validateUrl,
            ),
            
            const SizedBox(height: AppSpacing.xl),
            
            // Professional Summary
            const SectionDivider(label: 'Professional Summary'),
            const SizedBox(height: AppSpacing.lg),
            
            // Summary
            AppInput(
              label: 'About You',
              hint: 'Write 2-3 sentences about your background, skills and career goals...',
              controller: _summaryController,
              maxLines: 5,
              maxLength: 500,
              validator: (value) {
                if (value != null && value.length > 500) {
                  return 'Summary must be 500 characters or less';
                }
                return null;
              },
            ),
            
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhotoSection(String? photoUrl) {
    return Column(
      children: [
        // Avatar
        CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.primary,
          backgroundImage: _selectedPhoto != null 
              ? FileImage(_selectedPhoto!) as ImageProvider
              : (photoUrl != null ? NetworkImage(photoUrl) as ImageProvider : null),
          child: _selectedPhoto == null && photoUrl == null
              ? Text(
                  _getInitials(),
                  style: AppTypography.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // Change Photo Button
        TextButton(
          onPressed: _pickPhoto,
          child: Text(
            'Change Photo',
            style: AppTypography.body.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  String _getInitials() {
    // Mock user data since currentUserProvider is not available
    const fullName = 'John Doe';
    if (fullName.isNotEmpty) {
      final names = fullName.split(' ');
      if (names.length >= 2) {
        return '${names[0][0]}${names[1][0]}'.toUpperCase();
      } else if (names.isNotEmpty) {
        return names[0][0].toUpperCase();
      }
    }
    return 'U';
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedPhoto = File(pickedFile.path);
      });
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 7) {
      return 'Phone number must have at least 7 digits';
    }
    return null;
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) return null;
    
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      value = 'https://$value';
    }
    
    final urlPattern = r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
    if (!RegExp(urlPattern).hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload photo if selected
      if (_selectedPhoto != null) {
        await ref.read(cvProfileProvider.notifier).uploadPhoto(_selectedPhoto!);
      }

      // Update profile data
      final data = {
        'phone': _phoneController.text.trim(),
        'city': _cityController.text.trim(),
        'country': _countryController.text.trim(),
        'linkedin': _linkedinController.text.trim(),
        'github': _githubController.text.trim(),
        'portfolio': _portfolioController.text.trim(),
        'summary': _summaryController.text.trim(),
      };

      await ref.read(cvProfileProvider.notifier).updateProfile(data);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}