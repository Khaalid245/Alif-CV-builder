import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Responsive breakpoints for enterprise design
class ResponsiveBreakpoints {
  static const double mobile = 480;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double largeDesktop = 1440;

  // Grid columns based on screen size
  static int getGridColumns(double width) {
    if (width >= largeDesktop) return 6;
    if (width >= desktop) return 4;
    if (width >= tablet) return 3;
    return 2;
  }

  // Padding based on screen size
  static EdgeInsets getScreenPadding(double width) {
    if (width >= desktop) return const EdgeInsets.all(32);
    if (width >= tablet) return const EdgeInsets.all(24);
    return const EdgeInsets.all(16);
  }

  // Content max width for readability
  static double getContentMaxWidth(double width) {
    // Always return full width for CV builder app
    return width;
  }
}

// Performance-optimized responsive builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveConstraints constraints)
      builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final responsiveConstraints =
            ResponsiveConstraints.fromConstraints(constraints);
        return builder(context, responsiveConstraints);
      },
    );
  }
}

class ResponsiveConstraints {
  final double width;
  final double height;
  final DeviceType deviceType;
  final int gridColumns;
  final EdgeInsets padding;
  final double contentMaxWidth;

  ResponsiveConstraints._({
    required this.width,
    required this.height,
    required this.deviceType,
    required this.gridColumns,
    required this.padding,
    required this.contentMaxWidth,
  });

  factory ResponsiveConstraints.fromConstraints(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final height = constraints.maxHeight;

    DeviceType deviceType;
    if (width >= ResponsiveBreakpoints.desktop) {
      deviceType = DeviceType.desktop;
    } else if (width >= ResponsiveBreakpoints.tablet) {
      deviceType = DeviceType.tablet;
    } else {
      deviceType = DeviceType.mobile;
    }

    return ResponsiveConstraints._(
      width: width,
      height: height,
      deviceType: deviceType,
      gridColumns: ResponsiveBreakpoints.getGridColumns(width),
      padding: ResponsiveBreakpoints.getScreenPadding(width),
      contentMaxWidth: ResponsiveBreakpoints.getContentMaxWidth(width),
    );
  }

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isDesktop => deviceType == DeviceType.desktop;
}

enum DeviceType { mobile, tablet, desktop }

// Performance-optimized animated widget
class PerformantAnimatedWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool slideIn;
  final bool fadeIn;
  final bool scaleIn;
  final Offset? slideOffset;

  const PerformantAnimatedWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
    this.slideIn = false,
    this.fadeIn = true,
    this.scaleIn = false,
    this.slideOffset,
  });

  @override
  State<PerformantAnimatedWidget> createState() =>
      _PerformantAnimatedWidgetState();
}

class _PerformantAnimatedWidgetState extends State<PerformantAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: widget.fadeIn ? 0.0 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _slideAnimation = Tween<Offset>(
      begin: widget.slideIn
          ? (widget.slideOffset ?? const Offset(0, 0.3))
          : Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _scaleAnimation = Tween<double>(
      begin: widget.scaleIn ? 0.8 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    // Start animation on next frame to avoid jank
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    if (widget.scaleIn) {
      child = ScaleTransition(
        scale: _scaleAnimation,
        child: child,
      );
    }

    if (widget.slideIn) {
      child = SlideTransition(
        position: _slideAnimation,
        child: child,
      );
    }

    if (widget.fadeIn) {
      child = FadeTransition(
        opacity: _fadeAnimation,
        child: child,
      );
    }

    return child;
  }
}

// Performance-optimized list builder
class PerformantListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Axis scrollDirection;

  const PerformantListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Wrap each item in RepaintBoundary to prevent unnecessary repaints
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      scrollDirection: scrollDirection,
      // Optimize for performance
      cacheExtent: 250.0, // Cache items outside viewport
      addAutomaticKeepAlives: false, // Don't keep items alive unnecessarily
      addRepaintBoundaries: false, // We handle this manually
    );
  }
}

// Performance-optimized grid builder
class PerformantGridView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsets? padding;
  final double childAspectRatio;

  const PerformantGridView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.crossAxisCount,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
    this.padding,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index),
        );
      },
      padding: padding,
      cacheExtent: 250.0,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
    );
  }
}

// Smooth micro-interaction button
class MicroInteractionButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  final double scaleDown;
  final Color? splashColor;

  const MicroInteractionButton({
    super.key,
    required this.child,
    this.onPressed,
    this.duration = const Duration(milliseconds: 150),
    this.scaleDown = 0.95,
    this.splashColor,
  });

  @override
  State<MicroInteractionButton> createState() => _MicroInteractionButtonState();
}

class _MicroInteractionButtonState extends State<MicroInteractionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? _onTapDown : null,
      onTapUp: widget.onPressed != null ? _onTapUp : null,
      onTapCancel: widget.onPressed != null ? _onTapCancel : null,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

// Optimized image loading with caching
class OptimizedImage extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width?.toInt(),
        cacheHeight: height?.toInt(),
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultError();
        },
      );
    }

    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width?.toInt(),
        cacheHeight: height?.toInt(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _buildDefaultPlaceholder(loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildDefaultError();
        },
      );
    }

    return errorWidget ?? _buildDefaultError();
  }

  Widget _buildDefaultPlaceholder(ImageChunkEvent? loadingProgress) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress?.expectedTotalBytes != null
              ? loadingProgress!.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Icon(
        Icons.error_outline,
        color: Colors.grey,
      ),
    );
  }
}
