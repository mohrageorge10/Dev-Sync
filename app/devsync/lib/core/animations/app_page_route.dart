import 'package:devsync/core/animations/app_animations.dart';
import 'package:flutter/material.dart';

// Clean, snappy fade + subtle upward rise page transition.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required WidgetBuilder builder,
    super.settings,
    Duration duration = AppAnimations.fast,
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: const Duration(milliseconds: 160),
          pageBuilder: (context, _, _) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fade = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
              reverseCurve: Curves.easeIn,
            );
            final scale = Tween<double>(begin: 0.985, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );
            return FadeTransition(
              opacity: fade,
              child: ScaleTransition(scale: scale, child: child),
            );
          },
        );
}
