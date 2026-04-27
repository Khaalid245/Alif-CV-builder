import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
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

  void _loadExistingData() {
    final profileAsync = ref.read(cvProfileProvider);
    profileAsync.whenData((profile) {
      _phoneController.text = profile.phone ?? '';
      _cityController.text = profile.city ?? '';
      _countryController.text = profile.country ?? '';
      _linkedinController.text = profile.linkedin ?? '';
      _githubController.text = profile.github ?? '';
      _portfolioController.text = profile.portfolio ?? '';
      _summaryController.text = profile.summary ?? '';
    });
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedPhoto = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
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
      
      if (_selectedPhoto != null) {
        await ref.read(cvProfileProvider.notifier).uploadPhoto(_selectedPhoto!);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return null;
    
    final phonePattern = RegExp(r'^\+?[\d\s\-\(\)]{7,}$');
    if (!phonePattern.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(cvProfileProvider);
    
    return profileAsync.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
      data: (profile) => SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Photo
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primary,
                      backgroundImage: _selectedPhoto != null
                          ? FileImage(_selectedPhoto!)
                          : (profile.photoUrl != null
                              ? NetworkImage(profile.photoUrl!)
                              : null) as ImageProvider?,
                      child: _selectedPhoto == null && profile.photoUrl == null
                          ? Text(
                              profile.fullName.isNotEmpty
                                  ? profile.fullName.split(' ').map((n) => n[0]).take(2).join()
                                  : 'U',
                              style: AppTypography.h2.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    SizedBox(height: AppSpacing.sm),
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
                ),
              ),
              
              SizedBox(height: AppSpacing.xl),
              
              SectionDivider(label: 'Basic Information'),
              
              SizedBox(height: AppSpacing.lg),
              
              // Full Name (read-only)
              AppInput(
                label: 'Full Name',
                hint: 'Your full name',
                value: profile.fullName,
                enabled: false,
                suffixIcon: Icon(
                  Icons.lock,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'To change your name contact admin',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              
              SizedBox(height: AppSpacing.md),
              
              AppInput(
                label: 'Phone Number',
                hint: '+1 234 567 8900',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              
              SizedBox(height: AppSpacing.md),
              
              AppInput(
                label: 'City',
                hint: 'e.g. New York',
                controller: _cityController,
              ),
              
              SizedBox(height: AppSpacing.md),
              
              AppInput(
                label: 'Country',
                hint: 'e.g. United States',
                controller: _countryController,
              ),
              
              SizedBox(height: AppSpacing.xl),
              
              SectionDivider(label: 'Online Presence'),
              
              SizedBox(height: AppSpacing.lg),
              
              AppInput(
                label: 'LinkedIn Profile',
                hint: 'linkedin.com/in/yourname',
                controller: _linkedinController,
                keyboardType: TextInputType.url,
                prefixIcon: Icon(Icons.link, color: AppColors.primary),
                validator: _validateUrl,
              ),
              
              SizedBox(height: AppSpacing.md),
              
              AppInput(
                label: 'GitHub Profile',
                hint: 'github.com/yourname',
                controller: _githubController,
                keyboardType: TextInputType.url,
                prefixIcon: Icon(Icons.code, color: AppColors.primary),
                validator: _validateUrl,
              ),
              
              SizedBox(height: AppSpacing.md),
              
              AppInput(
                label: 'Portfolio Website',
                hint: 'yourwebsite.com',
                controller: _portfolioController,
                keyboardType: TextInputType.url,
                prefixIcon: Icon(Icons.link, color: AppColors.primary),
                validator: _validateUrl,
              ),
              
              SizedBox(height: AppSpacing.xl),
              
              SectionDivider(label: 'Professional Summary'),
              
              SizedBox(height: AppSpacing.lg),
              
              AppInput(
                label: 'About You',
                hint: 'Write 2-3 sentences about your background, skills and career goals...',
                controller: _summaryController,
                maxLines: 5,
                maxLength: 500,
              ),
              
              SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
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
}