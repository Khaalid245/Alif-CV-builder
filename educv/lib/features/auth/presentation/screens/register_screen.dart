import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/premium_portfolio_colors.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../../../public/presentation/widgets/public_layout.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _fullNameFocusNode = FocusNode();
  final _studentIdFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _termsAccepted = false;
  bool _marketingConsent = false;
  bool _dataProcessingConsent = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameFocusNode.dispose();
    _studentIdFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String? _validateStudentId(String? value) {
    if (value == null || value.trim().isEmpty) return 'Student ID is required';
    if (value.contains(' ')) return 'Student ID cannot contain spaces';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'At least 8 characters required';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_termsAccepted || !_dataProcessingConsent) {
      SnackbarHelper.showError(
        context,
        'Please accept the Terms of Service and data processing consent',
      );
      return;
    }
    ref.read(registerProvider.notifier).register(
          email: _emailController.text,
          fullName: _fullNameController.text,
          studentId: _studentIdController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          termsAccepted: _termsAccepted,
          marketingConsent: _marketingConsent,
          dataProcessingConsent: _dataProcessingConsent,
        );
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerProvider);

    ref.listen(registerProvider, (previous, next) {
      next.when(
        data: (authResponse) {
          if (authResponse != null) context.go('/cv/dashboard');
        },
        error: (error, _) =>
            SnackbarHelper.showError(context, error.toString()),
        loading: () {},
      );
    });

    return PublicLayout(
      showFooter: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _RegisterGridPainter()),
            ),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 48),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 40),
                          _buildCard(registerState),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: PremiumPortfolioColors.accentPurple.withValues(alpha: 0.2),
            ),
          ),
          child: const Text(
            'STUDENT PORTAL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: PremiumPortfolioColors.accentPurple,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                PremiumPortfolioColors.accentPurple,
                PremiumPortfolioColors.accentBlue,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color:
                    PremiumPortfolioColors.accentPurple.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.userPlus,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Create your account',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: PremiumPortfolioColors.primaryText,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Fill in your details and start building your professional CV',
          style: TextStyle(
            fontSize: 16,
            color: PremiumPortfolioColors.secondaryText,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCard(AsyncValue registerState) {
    return _HoverCard(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                label: 'Full Name',
                hint: 'As it appears on official documents',
                controller: _fullNameController,
                focusNode: _fullNameFocusNode,
                icon: LucideIcons.user,
                textInputAction: TextInputAction.next,
                validator: Validators.name,
                onEditingComplete: () => _studentIdFocusNode.requestFocus(),
              ),
              const SizedBox(height: 20),
              _buildField(
                label: 'Student ID',
                hint: 'e.g. STU2024001',
                controller: _studentIdController,
                focusNode: _studentIdFocusNode,
                icon: LucideIcons.hash,
                textInputAction: TextInputAction.next,
                validator: _validateStudentId,
                onEditingComplete: () => _emailFocusNode.requestFocus(),
              ),
              const SizedBox(height: 20),
              _buildField(
                label: 'University Email',
                hint: 'you@university.edu',
                controller: _emailController,
                focusNode: _emailFocusNode,
                icon: LucideIcons.mail,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
                onEditingComplete: () => _passwordFocusNode.requestFocus(),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'Password',
                hint: 'Minimum 8 characters',
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscure: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                validator: _validatePassword,
                textInputAction: TextInputAction.next,
                onEditingComplete: () =>
                    _confirmPasswordFocusNode.requestFocus(),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                label: 'Confirm Password',
                hint: 'Re-enter your password',
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                validator: _validateConfirmPassword,
                textInputAction: TextInputAction.done,
                onEditingComplete: _submitForm,
              ),
              const SizedBox(height: 24),
              _buildConsentSection(),
              const SizedBox(height: 28),
              _buildSubmitButton(registerState),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: PremiumPortfolioColors.secondaryText,
                      fontSize: 15,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: PremiumPortfolioColors.accentPurple,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    VoidCallback? onEditingComplete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: PremiumPortfolioColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onEditingComplete: onEditingComplete,
          style: const TextStyle(
            fontSize: 16,
            color: PremiumPortfolioColors.primaryText,
          ),
          decoration: _inputDecoration(hint, icon),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    TextInputAction? textInputAction,
    VoidCallback? onEditingComplete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: PremiumPortfolioColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscure,
          textInputAction: textInputAction,
          validator: validator,
          onEditingComplete: onEditingComplete,
          style: const TextStyle(
            fontSize: 16,
            color: PremiumPortfolioColors.primaryText,
          ),
          decoration: _inputDecoration(hint, LucideIcons.lock).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? LucideIcons.eyeOff : LucideIcons.eye,
                color: PremiumPortfolioColors.secondaryText,
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: PremiumPortfolioColors.secondaryText),
      prefixIcon:
          Icon(icon, color: PremiumPortfolioColors.secondaryText, size: 20),
      filled: true,
      fillColor: PremiumPortfolioColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PremiumPortfolioColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PremiumPortfolioColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: PremiumPortfolioColors.accentPurple, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: PremiumPortfolioColors.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: PremiumPortfolioColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.all(16),
    );
  }

  Widget _buildConsentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PremiumPortfolioColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PremiumPortfolioColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Before continuing',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: PremiumPortfolioColors.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          _buildConsentRow(
            value: _termsAccepted,
            text: 'I agree to the Terms of Service *',
            onChanged: (v) => setState(() => _termsAccepted = v ?? false),
          ),
          const SizedBox(height: 12),
          _buildConsentRow(
            value: _dataProcessingConsent,
            text: 'I consent to data processing for CV generation *',
            onChanged: (v) =>
                setState(() => _dataProcessingConsent = v ?? false),
          ),
          const SizedBox(height: 12),
          _buildConsentRow(
            value: _marketingConsent,
            text: 'I accept marketing communications (optional)',
            onChanged: (v) => setState(() => _marketingConsent = v ?? false),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentRow({
    required bool value,
    required String text,
    required ValueChanged<bool?> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: PremiumPortfolioColors.accentPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: const BorderSide(
                  color: PremiumPortfolioColors.borderLight, width: 1.5),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: PremiumPortfolioColors.secondaryText,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AsyncValue registerState) {
    final isLoading = registerState.isLoading;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isLoading
                ? null
                : const LinearGradient(
                    colors: [
                      PremiumPortfolioColors.accentPurple,
                      PremiumPortfolioColors.accentBlue,
                    ],
                  ),
            color: isLoading ? PremiumPortfolioColors.borderLight : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isLoading
                ? null
                : [
                    BoxShadow(
                      color: PremiumPortfolioColors.accentPurple
                          .withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _RegisterGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PremiumPortfolioColors.gridOverlay
      ..strokeWidth = 1;
    const gridSize = 50.0;
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _elevation,
        builder: (context, child) => Container(
          decoration: BoxDecoration(
            color: PremiumPortfolioColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: PremiumPortfolioColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: 0.05 + 0.1 * _elevation.value),
                blurRadius: 20 + 20 * _elevation.value,
                offset: Offset(0, 4 + 8 * _elevation.value),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
