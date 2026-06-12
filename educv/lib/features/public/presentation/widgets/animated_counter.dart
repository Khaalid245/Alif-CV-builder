import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedCounter extends StatefulWidget {
  final String value;
  final Duration delay;
  final TextStyle textStyle;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.delay,
    required this.textStyle,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _targetNumber;
  String _suffix = '';

  @override
  void initState() {
    super.initState();
    _parseValue();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: _targetNumber?.toDouble() ?? 0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  void _parseValue() {
    final cleanValue = widget.value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanValue.isNotEmpty) {
      _targetNumber = int.tryParse(cleanValue);
      _suffix = widget.value.replaceAll(cleanValue, '');
    } else {
      _targetNumber = null;
      _suffix = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_targetNumber == null) {
      return Text(
        widget.value,
        style: widget.textStyle,
      )
          .animate(delay: widget.delay)
          .fadeIn(duration: 800.ms)
          .slideY(begin: 0.3, end: 0);
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentValue = _animation.value.round();
        final formattedValue = _formatNumber(currentValue);
        return Text(
          '$formattedValue$_suffix',
          style: widget.textStyle,
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      final thousands = (number / 1000).toStringAsFixed(1);
      if (thousands.endsWith('.0')) {
        return '${thousands.substring(0, thousands.length - 2)},${(number % 1000).toString().padLeft(3, '0')}';
      }
      return thousands.replaceAll('.', ',');
    }
    return number.toString();
  }
}
