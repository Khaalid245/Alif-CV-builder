import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/premium_saas_theme.dart';

class PremiumTopNavigation extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final int notificationCount;

  const PremiumTopNavigation({
    super.key,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.notificationCount = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  State<PremiumTopNavigation> createState() => _PremiumTopNavigationState();
}

class _PremiumTopNavigationState extends State<PremiumTopNavigation>
    with TickerProviderStateMixin {
  late AnimationController _searchController;
  late AnimationController _notificationController;
  late Animation<double> _searchFocusAnimation;
  late Animation<double> _notificationPulseAnimation;
  
  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchController = AnimationController(
      duration: PremiumSaaSTheme.animationMedium,
      vsync: this,
    );
    _notificationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _searchFocusAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _searchController, curve: PremiumSaaSTheme.curveDefault),
    );
    _notificationPulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _notificationController, curve: Curves.easeInOut),
    );

    _searchFocusNode.addListener(() {
      setState(() {
        _isSearchFocused = _searchFocusNode.hasFocus;
        if (_isSearchFocused) {
          _searchController.forward();
        } else {
          _searchController.reverse();
        }
      });
    });

    if (widget.notificationCount > 0) {
      _notificationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PremiumTopNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.notificationCount != oldWidget.notificationCount) {
      if (widget.notificationCount > 0) {
        _notificationController.repeat(reverse: true);
      } else {
        _notificationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notificationController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.preferredSize.height,
      decoration: BoxDecoration(
        color: PremiumSaaSTheme.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: PremiumSaaSTheme.lightBorder,
            width: 1,
          ),
        ),
        boxShadow: PremiumSaaSTheme.shadowSoft,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: PremiumSaaSTheme.space6,
          vertical: PremiumSaaSTheme.space3,
        ),
        child: Row(
          children: [
            if (widget.onMenuPressed != null) ...[
              _buildMenuButton(),
              SizedBox(width: PremiumSaaSTheme.space4),
            ],
            _buildWorkspaceSelector(),
            SizedBox(width: PremiumSaaSTheme.space8),
            Expanded(child: _buildIntelligentSearch()),
            SizedBox(width: PremiumSaaSTheme.space6),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onMenuPressed,
        borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusMd),
        child: Container(
          padding: EdgeInsets.all(PremiumSaaSTheme.space2),
          child: Icon(
            LucideIcons.menu,
            color: PremiumSaaSTheme.textSecondary,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkspaceSelector() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: PremiumSaaSTheme.space3,
        vertical: PremiumSaaSTheme.space2,
      ),
      decoration: BoxDecoration(
        color: PremiumSaaSTheme.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusMd),
        border: Border.all(color: PremiumSaaSTheme.lightBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: PremiumSaaSTheme.heroGradient,
              borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusSm),
            ),
            child: Icon(
              LucideIcons.briefcase,
              color: PremiumSaaSTheme.textInverse,
              size: 12,
            ),
          ),
          SizedBox(width: PremiumSaaSTheme.space2),
          Text(
            'Personal Workspace',
            style: PremiumSaaSTheme.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: PremiumSaaSTheme.space1),
          Icon(
            LucideIcons.chevronDown,
            color: PremiumSaaSTheme.textTertiary,
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildIntelligentSearch() {
    return AnimatedBuilder(
      animation: _searchFocusAnimation,
      builder: (context, child) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            decoration: BoxDecoration(
              color: _isSearchFocused
                  ? PremiumSaaSTheme.lightSurface
                  : PremiumSaaSTheme.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusLg),
              border: Border.all(
                color: _isSearchFocused
                    ? PremiumSaaSTheme.primaryPurple.withOpacity(0.3)
                    : PremiumSaaSTheme.lightBorder,
                width: _isSearchFocused ? 2 : 1,
              ),
              boxShadow: _isSearchFocused ? PremiumSaaSTheme.shadowMedium : null,
            ),
            child: TextField(
              controller: _searchTextController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search CVs, ask AI, or type a command...',
                hintStyle: PremiumSaaSTheme.bodyMedium.copyWith(
                  color: PremiumSaaSTheme.textTertiary,
                ),
                prefixIcon: Container(
                  padding: EdgeInsets.all(PremiumSaaSTheme.space3),
                  child: Icon(
                    LucideIcons.search,
                    color: _isSearchFocused
                        ? PremiumSaaSTheme.primaryPurple
                        : PremiumSaaSTheme.textTertiary,
                    size: 18,
                  ),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchTextController.text.isNotEmpty)
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _searchTextController.clear();
                            setState(() {});
                          },
                          borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusSm),
                          child: Container(
                            padding: EdgeInsets.all(PremiumSaaSTheme.space1),
                            child: Icon(
                              LucideIcons.x,
                              color: PremiumSaaSTheme.textTertiary,
                              size: 14,
                            ),
                          ),
                        ),
                      )
                    else ...[
                      Container(
                        margin: EdgeInsets.only(right: PremiumSaaSTheme.space2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildShortcutKey('⌘'),
                            _buildShortcutKey('K'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: PremiumSaaSTheme.space4,
                  vertical: PremiumSaaSTheme.space3,
                ),
              ),
              style: PremiumSaaSTheme.bodyMedium,
              onChanged: (value) => setState(() {}),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShortcutKey(String key) {
    return Container(
      margin: EdgeInsets.only(left: PremiumSaaSTheme.space1),
      padding: EdgeInsets.symmetric(
        horizontal: PremiumSaaSTheme.space2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: PremiumSaaSTheme.lightBorder,
        borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusXs),
        border: Border.all(
          color: PremiumSaaSTheme.lightBorder,
        ),
      ),
      child: Text(
        key,
        style: PremiumSaaSTheme.labelSmall.copyWith(
          color: PremiumSaaSTheme.textTertiary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildAIAssistantButton(),
        SizedBox(width: PremiumSaaSTheme.space3),
        _buildNotificationButton(),
        SizedBox(width: PremiumSaaSTheme.space3),
        _buildProfileButton(),
      ],
    );
  }

  Widget _buildAIAssistantButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusMd),
        child: Container(
          padding: EdgeInsets.all(PremiumSaaSTheme.space2),
          decoration: BoxDecoration(
            gradient: PremiumSaaSTheme.heroGradient,
            borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusMd),
            boxShadow: PremiumSaaSTheme.shadowGlow,
          ),
          child: Icon(
            LucideIcons.sparkles,
            color: PremiumSaaSTheme.textInverse,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return AnimatedBuilder(
      animation: _notificationPulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.notificationCount > 0 ? _notificationPulseAnimation.value : 1.0,
          child: Stack(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onNotificationPressed,
                  borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusMd),
                  child: Container(
                    padding: EdgeInsets.all(PremiumSaaSTheme.space2),
                    child: Icon(
                      LucideIcons.bell,
                      color: PremiumSaaSTheme.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ),
              if (widget.notificationCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: EdgeInsets.all(PremiumSaaSTheme.space1),
                    decoration: BoxDecoration(
                      color: PremiumSaaSTheme.accentRose,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: PremiumSaaSTheme.accentRose.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      widget.notificationCount > 99 ? '99+' : '${widget.notificationCount}',
                      style: PremiumSaaSTheme.labelSmall.copyWith(
                        color: PremiumSaaSTheme.textInverse,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onProfilePressed,
        borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusLg),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: PremiumSaaSTheme.space3,
            vertical: PremiumSaaSTheme.space2,
          ),
          decoration: BoxDecoration(
            color: PremiumSaaSTheme.lightSurfaceVariant,
            borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusLg),
            border: Border.all(color: PremiumSaaSTheme.lightBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: PremiumSaaSTheme.heroGradient,
                  borderRadius: BorderRadius.circular(PremiumSaaSTheme.radiusMd),
                ),
                child: Center(
                  child: Text(
                    'W',
                    style: PremiumSaaSTheme.labelMedium.copyWith(
                      color: PremiumSaaSTheme.textInverse,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: PremiumSaaSTheme.space2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'William',
                    style: PremiumSaaSTheme.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Premium',
                    style: PremiumSaaSTheme.bodySmall.copyWith(
                      color: PremiumSaaSTheme.primaryPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(width: PremiumSaaSTheme.space2),
              Icon(
                LucideIcons.chevronDown,
                color: PremiumSaaSTheme.textTertiary,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}