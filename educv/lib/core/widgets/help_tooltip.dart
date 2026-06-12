import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/premium_portfolio_colors.dart';

class HelpTooltip extends StatefulWidget {
  final String title;
  final String message;
  final Widget child;
  final TooltipPosition position;
  final IconData? icon;

  const HelpTooltip({
    super.key,
    required this.title,
    required this.message,
    required this.child,
    this.position = TooltipPosition.top,
    this.icon,
  });

  @override
  State<HelpTooltip> createState() => _HelpTooltipState();
}

class _HelpTooltipState extends State<HelpTooltip>
    with SingleTickerProviderStateMixin {
  bool _isVisible = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showTooltip() {
    setState(() {
      _isVisible = true;
    });
    _animationController.forward();
  }

  void _hideTooltip() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _isVisible ? _hideTooltip : _showTooltip,
          child: widget.child,
        ),
        if (_isVisible)
          Positioned.fill(
            child: GestureDetector(
              onTap: _hideTooltip,
              child: Container(
                color: Colors.transparent,
                child: _buildTooltipContent(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTooltipContent() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _buildTooltipCard(),
          ),
        );
      },
    );
  }

  Widget _buildTooltipCard() {
    return Align(
      alignment: _getAlignment(),
      child: Container(
        margin: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: PremiumPortfolioColors.accentPurple.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PremiumPortfolioColors.accentPurple.withOpacity(0.1),
                    PremiumPortfolioColors.accentBlue.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          PremiumPortfolioColors.accentPurple,
                          PremiumPortfolioColors.accentBlue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.icon ?? LucideIcons.helpCircle,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: PremiumPortfolioColors.primaryText,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _hideTooltip,
                    icon: const Icon(
                      LucideIcons.x,
                      size: 16,
                      color: PremiumPortfolioColors.secondaryText,
                    ),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(24, 24),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 14,
                  color: PremiumPortfolioColors.secondaryText,
                  height: 1.5,
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: PremiumPortfolioColors.background,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    LucideIcons.lightbulb,
                    size: 14,
                    color: PremiumPortfolioColors.warning,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Tip: Click anywhere to close',
                    style: TextStyle(
                      fontSize: 12,
                      color: PremiumPortfolioColors.secondaryText,
                      fontStyle: FontStyle.italic,
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

  Alignment _getAlignment() {
    switch (widget.position) {
      case TooltipPosition.top:
        return Alignment.topCenter;
      case TooltipPosition.bottom:
        return Alignment.bottomCenter;
      case TooltipPosition.left:
        return Alignment.centerLeft;
      case TooltipPosition.right:
        return Alignment.centerRight;
      case TooltipPosition.topLeft:
        return Alignment.topLeft;
      case TooltipPosition.topRight:
        return Alignment.topRight;
      case TooltipPosition.bottomLeft:
        return Alignment.bottomLeft;
      case TooltipPosition.bottomRight:
        return Alignment.bottomRight;
    }
  }
}

enum TooltipPosition {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

// Quick help button widget
class QuickHelpButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const QuickHelpButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: PremiumPortfolioColors.accentPurple.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed ?? () => _showHelpDialog(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.helpCircle,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'Need Help?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const HelpDialog(),
    );
  }
}

// Help dialog with common questions
class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PremiumPortfolioColors.accentPurple.withOpacity(0.1),
                    PremiumPortfolioColors.accentBlue.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          PremiumPortfolioColors.accentPurple,
                          PremiumPortfolioColors.accentBlue,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      LucideIcons.helpCircle,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Help & Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: PremiumPortfolioColors.primaryText,
                          ),
                        ),
                        Text(
                          'Common questions and tips',
                          style: TextStyle(
                            fontSize: 14,
                            color: PremiumPortfolioColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      LucideIcons.x,
                      color: PremiumPortfolioColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHelpSection(
                      'Getting Started',
                      [
                        HelpItem(
                          question: 'How do I create my first CV?',
                          answer:
                              'Click "Build My CV" in the sidebar, then fill out each section step by step. Start with Personal Information and work your way through.',
                        ),
                        HelpItem(
                          question: 'Which sections are required?',
                          answer:
                              'Personal Information and Education are required. Other sections like Experience, Skills, and Projects are optional but recommended.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildHelpSection(
                      'Using the CV Builder',
                      [
                        HelpItem(
                          question: 'Can I save my progress?',
                          answer:
                              'Yes! Your information is automatically saved as you fill out each section. You can come back anytime to continue.',
                        ),
                        HelpItem(
                          question: 'How do I navigate between sections?',
                          answer:
                              'Use the step navigation at the top, the sidebar on the left, or the Previous/Next buttons at the bottom.',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildHelpSection(
                      'CV Templates',
                      [
                        HelpItem(
                          question: 'What are the different templates?',
                          answer:
                              'Classic (corporate/government), Modern (tech/creative), and Academic (research/education). You get all three automatically.',
                        ),
                        HelpItem(
                          question: 'How do I download my CV?',
                          answer:
                              'Complete your information, then go to "Preview CV" or "Download CVs" to generate and download your PDF files.',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: PremiumPortfolioColors.background,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    LucideIcons.mail,
                    size: 16,
                    color: PremiumPortfolioColors.accentPurple,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Still need help? Contact support',
                    style: TextStyle(
                      fontSize: 14,
                      color: PremiumPortfolioColors.secondaryText,
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

  Widget _buildHelpSection(String title, List<HelpItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: PremiumPortfolioColors.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildHelpItem(item)),
      ],
    );
  }

  Widget _buildHelpItem(HelpItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: PremiumPortfolioColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: PremiumPortfolioColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.answer,
            style: const TextStyle(
              fontSize: 13,
              color: PremiumPortfolioColors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class HelpItem {
  final String question;
  final String answer;

  HelpItem({
    required this.question,
    required this.answer,
  });
}
