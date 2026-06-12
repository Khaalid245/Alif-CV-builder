import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/premium_portfolio_colors.dart';
import '../widgets/public_layout.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedSubject = 'Account issue';
  bool _isLoading = false;
  bool _isSuccess = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _subjects = [
    'Account issue',
    'CV generation problem',
    'Template question',
    'Data deletion request',
    'Other',
  ];

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
    _nameController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PublicLayout(
      child: Container(
        decoration: const BoxDecoration(
          color: PremiumPortfolioColors.background,
        ),
        child: Stack(
          children: [
            // Grid overlay background
            _buildGridOverlay(),
            // Main content with animations
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildHeroSection(),
                    _buildContactSection(),
                    _buildFAQSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridOverlay() {
    return Positioned.fill(
      child: CustomPaint(
        painter: ContactGridPainter(),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:
                    PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: PremiumPortfolioColors.accentPurple
                      .withValues(alpha: 0.2),
                ),
              ),
              child: const Text(
                'GET IN TOUCH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PremiumPortfolioColors.accentPurple,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'We are here to help',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                color: PremiumPortfolioColors.primaryText,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: const Text(
                'Questions about your account, CV generation, or the platform? Reach out and we will respond within one business day.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: PremiumPortfolioColors.secondaryText,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;
            return isDesktop ? _buildContactDesktop() : _buildContactMobile();
          },
        ),
      ),
    );
  }

  Widget _buildContactDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildContactInfo(),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 1,
          child: _buildContactForm(),
        ),
      ],
    );
  }

  Widget _buildContactMobile() {
    return Column(
      children: [
        _buildContactInfo(),
        const SizedBox(height: 40),
        _buildContactForm(),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Information',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: PremiumPortfolioColors.primaryText,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 32),
        _buildContactCard(
          LucideIcons.building2,
          'Department',
          'University Career Center',
        ),
        const SizedBox(height: 20),
        _buildContactCard(
          LucideIcons.mapPin,
          'Address',
          '[University Address]',
        ),
        const SizedBox(height: 20),
        _buildContactCard(
          LucideIcons.mail,
          'Email',
          'support@university.edu',
        ),
        const SizedBox(height: 20),
        _buildContactCard(
          LucideIcons.clock,
          'Hours',
          'Mon–Fri, 8:00 AM – 5:00 PM',
        ),
      ],
    );
  }

  Widget _buildContactCard(IconData icon, String label, String value) {
    return _PremiumHoverCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    PremiumPortfolioColors.accentPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PremiumPortfolioColors.accentPurple
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                icon,
                size: 24,
                color: PremiumPortfolioColors.accentPurple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: PremiumPortfolioColors.secondaryText,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PremiumPortfolioColors.primaryText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return _PremiumHoverCard(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: _isSuccess ? _buildSuccessState() : _buildFormState(),
      ),
    );
  }

  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Send a message',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: PremiumPortfolioColors.primaryText,
            ),
          ),
          const SizedBox(height: 24),
          _buildPremiumInput(
            label: 'Your Name',
            hint: 'Enter your full name',
            controller: _nameController,
            validator: (value) =>
                value?.isEmpty == true ? 'Name is required' : null,
            icon: LucideIcons.user,
          ),
          const SizedBox(height: 20),
          _buildPremiumInput(
            label: 'Student ID',
            hint: 'Enter your student ID',
            controller: _studentIdController,
            validator: (value) =>
                value?.isEmpty == true ? 'Student ID is required' : null,
            icon: LucideIcons.hash,
          ),
          const SizedBox(height: 20),
          _buildPremiumInput(
            label: 'Email Address',
            hint: 'Enter your email address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty == true) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value!)) {
                return 'Enter a valid email';
              }
              return null;
            },
            icon: LucideIcons.mail,
          ),
          const SizedBox(height: 20),
          _buildSubjectDropdown(),
          const SizedBox(height: 20),
          _buildPremiumInput(
            label: 'Message',
            hint: 'Describe your issue or question...',
            controller: _messageController,
            maxLines: 5,
            validator: (value) =>
                value?.isEmpty == true ? 'Message is required' : null,
            icon: LucideIcons.messageSquare,
          ),
          const SizedBox(height: 32),
          _buildPremiumButton(),
        ],
      ),
    );
  }

  Widget _buildPremiumInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    IconData? icon,
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
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 16,
            color: PremiumPortfolioColors.primaryText,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: PremiumPortfolioColors.secondaryText,
            ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: PremiumPortfolioColors.secondaryText,
                    size: 20,
                  )
                : null,
            filled: true,
            fillColor: PremiumPortfolioColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: PremiumPortfolioColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: PremiumPortfolioColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: PremiumPortfolioColors.accentPurple,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: PremiumPortfolioColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subject',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: PremiumPortfolioColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedSubject,
          decoration: InputDecoration(
            filled: true,
            fillColor: PremiumPortfolioColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: PremiumPortfolioColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: PremiumPortfolioColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: PremiumPortfolioColors.accentPurple,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          items: _subjects
              .map((subject) => DropdownMenuItem(
                    value: subject,
                    child: Text(
                      subject,
                      style: const TextStyle(
                        fontSize: 16,
                        color: PremiumPortfolioColors.primaryText,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedSubject = value;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildPremiumButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                PremiumPortfolioColors.accentPurple,
                PremiumPortfolioColors.accentBlue,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color:
                    PremiumPortfolioColors.accentPurple.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Send Message',
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

  Widget _buildSuccessState() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: PremiumPortfolioColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(32),
          ),
          child: const Icon(
            LucideIcons.checkCircle,
            size: 32,
            color: PremiumPortfolioColors.success,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Message sent!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: PremiumPortfolioColors.primaryText,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'We will get back to you within one business day.',
          style: TextStyle(
            fontSize: 16,
            color: PremiumPortfolioColors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _resetForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: PremiumPortfolioColors.background,
            foregroundColor: PremiumPortfolioColors.primaryText,
            side: const BorderSide(color: PremiumPortfolioColors.borderLight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Send another'),
        ),
      ],
    );
  }

  Widget _buildFAQSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: PremiumPortfolioColors.primaryText,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            Column(
              children: [
                _buildFAQItem(
                  'Is EduCV free to use?',
                  'Yes. EduCV is completely free for all enrolled students at our university.',
                ),
                _buildFAQItem(
                  'Who can see my CV information?',
                  'Only you can view and download your CVs. Administrators can verify accounts but cannot access your CV content.',
                ),
                _buildFAQItem(
                  'Can I delete my account and data?',
                  'Yes. Go to Account Settings → Request Data Deletion. Your data is removed within 30 days.',
                ),
                _buildFAQItem(
                  'Which template should I choose?',
                  'Modern for tech and startup roles, Classic for corporate and government, Academic for research.',
                ),
                _buildFAQItem(
                  'Can I update my CV after generating?',
                  'Yes. Edit your information anytime and regenerate fresh PDFs. History is preserved.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: _PremiumHoverCard(
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PremiumPortfolioColors.primaryText,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 14,
                  color: PremiumPortfolioColors.secondaryText,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // For MVP: launch mailto
    final uri = Uri.parse('mailto:support@university.edu'
        '?subject=${Uri.encodeComponent(_selectedSubject)}'
        '&body=${Uri.encodeComponent(_messageController.text)}');

    try {
      await launchUrl(uri);
    } catch (e) {
      // Handle error silently for now
    }

    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
  }

  void _resetForm() {
    setState(() {
      _isSuccess = false;
      _nameController.clear();
      _studentIdController.clear();
      _emailController.clear();
      _messageController.clear();
      _selectedSubject = _subjects.first;
    });
  }
}

class _PremiumHoverCard extends StatefulWidget {
  final Widget child;

  const _PremiumHoverCard({required this.child});

  @override
  State<_PremiumHoverCard> createState() => _PremiumHoverCardState();
}

class _PremiumHoverCardState extends State<_PremiumHoverCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _elevationAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: PremiumPortfolioColors.cardBackground,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: PremiumPortfolioColors.borderLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                      alpha: 0.05 + (0.1 * _elevationAnimation.value)),
                  blurRadius: 20 + (20 * _elevationAnimation.value),
                  offset: Offset(0, 4 + (8 * _elevationAnimation.value)),
                ),
              ],
            ),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class ContactGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PremiumPortfolioColors.gridOverlay
      ..strokeWidth = 1;

    const gridSize = 50.0;

    // Draw vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
