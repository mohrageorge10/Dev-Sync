import 'package:devsync/core/animations/app_animations.dart';
import 'package:flutter/material.dart';

// Entrance animation combining fade and vertical slide with optional stagger delay.
class AppFadeSlide extends StatefulWidget {
  const AppFadeSlide({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppAnimations.medium,
    this.offsetY = 16,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;

  @override
  State<AppFadeSlide> createState() => _AppFadeSlideState();
}

class _AppFadeSlideState extends State<AppFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: AppAnimations.easeOut,
  );
  late final Animation<double> _slide = Tween<double>(
    begin: widget.offsetY,
    end: 0,
  ).animate(
    CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
