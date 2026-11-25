import 'package:flutter/material.dart';

// Centralized animation durations and curves.
abstract final class AppAnimations {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration medium = Duration(milliseconds: 380);
  static const Duration shimmer = Duration(milliseconds: 1400);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve spring = Curves.easeOutBack;
}
