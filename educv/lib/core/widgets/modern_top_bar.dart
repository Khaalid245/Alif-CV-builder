import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/enterprise_theme.dart';
import '../widgets/enterprise_ui_components.dart';

class ModernTopBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final int notificationCount;

  const ModernTopBar({
    super.key,
    required this.title,
    this.showSearch = true,
    this.onMenuPressed,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.notificationCount = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  State<ModernTopBar> createState() => _ModernTopBarState();
}

class _ModernTopBarState extends State<ModernTopBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: widget.preferredSize.height,
        decoration: BoxDecoration(
          color: EnterpriseTheme.cardBackground,
          border: Border(
            bottom: BorderSide(color: EnterpriseTheme.cardBorder),
          ),
          boxShadow: EnterpriseTheme.shadowSm,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: EnterpriseTheme.spacing24,
            vertical: EnterpriseTheme.spacing16,
          ),
          child: Row(
            children: [
              if (widget.onMenuPressed != null) ...[
                IconButton(
                  onPressed: widget.onMenuPressed,
                  icon: const Icon(
                    LucideIcons.menu,
                    color: EnterpriseTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: EnterpriseTheme.spacing16),
              ],
              _buildTitle(),
              const SizedBox(width: EnterpriseTheme.spacing32),
              if (widget.showSearch) ...[
                Expanded(child: _buildSearchBar()),
                const SizedBox(width: EnterpriseTheme.spacing24),
              ] else
                const Spacer(),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.title,
          style: EnterpriseTheme.h3.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          _getGreeting(),
          style: EnterpriseTheme.bodySmall.copyWith(
            color: EnterpriseTheme.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isSearchFocused
              ? EnterpriseTheme.white
              : EnterpriseTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(EnterpriseTheme.radiusMd),
          border: Border.all(
            color: _isSearchFocused
                ? EnterpriseTheme.primaryPurple.withOpacity(0.3)
                : EnterpriseTheme.cardBorder,
          ),
          boxShadow: _isSearchFocused ? EnterpriseTheme.shadowSm : null,
        ),
        child: TextField(
          controller: _searchController,
          onTap: () => setState(() => _isSearchFocused = true),
          onTapOutside: (_) => setState(() => _isSearchFocused = false),
          decoration: InputDecoration(
            hintText: 'Search CVs, templates, or ask AI...',
            hintStyle: EnterpriseTheme.bodyMedium.copyWith(
              color: EnterpriseTheme.textTertiary,
            ),
            prefixIcon: Icon(
              LucideIcons.search,
              color: _isSearchFocused
                  ? EnterpriseTheme.primaryPurple
                  : EnterpriseTheme.textTertiary,
              size: 20,
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(
                      LucideIcons.x,
                      color: EnterpriseTheme.textTertiary,
                      size: 16,
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.all(EnterpriseTheme.spacing8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: EnterpriseTheme.spacing8,
                      vertical: EnterpriseTheme.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: EnterpriseTheme.gray200,
                      borderRadius:
                          BorderRadius.circular(EnterpriseTheme.radiusXs),
                    ),
                    child: Text(
                      '⌘K',
                      style: EnterpriseTheme.labelSmall.copyWith(
                        color: EnterpriseTheme.textTertiary,
                      ),
                    ),
                  ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: EnterpriseTheme.spacing16,
              vertical: EnterpriseTheme.spacing12,
            ),
          ),
          style: EnterpriseTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _buildNotificationButton(),
        const SizedBox(width: EnterpriseTheme.spacing16),
        _buildProfileButton(),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          onPressed: widget.onNotificationPressed,
          icon: const Icon(
            LucideIcons.bell,
            color: EnterpriseTheme.textSecondary,
            size: 20,
          ),
        ),
        if (widget.notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: EnterpriseTheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                widget.notificationCount > 99
                    ? '99+'
                    : '${widget.notificationCount}',
                style: EnterpriseTheme.labelSmall.copyWith(
                  color: EnterpriseTheme.white,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileButton() {
    return GestureDetector(
      onTap: widget.onProfilePressed,
      child: Container(
        padding: const EdgeInsets.all(EnterpriseTheme.spacing8),
        decoration: BoxDecoration(
          color: EnterpriseTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(EnterpriseTheme.radiusMd),
          border: Border.all(color: EnterpriseTheme.cardBorder),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: EnterpriseTheme.primaryPurple,
              child: Text(
                'W',
                style: EnterpriseTheme.labelMedium.copyWith(
                  color: EnterpriseTheme.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: EnterpriseTheme.spacing8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'William',
                  style: EnterpriseTheme.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Premium',
                  style: EnterpriseTheme.bodySmall.copyWith(
                    color: EnterpriseTheme.primaryPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(width: EnterpriseTheme.spacing8),
            const Icon(
              LucideIcons.chevronDown,
              color: EnterpriseTheme.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
