import 'package:devsync/core/animations/app_animations.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Theme-aware shimmer animation wrapper (no external package required).
class AppShimmer extends StatefulWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppAnimations.shimmer,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? c.surface : c.border.withValues(alpha: 0.45);
    final highlight = isDark
        ? c.border.withValues(alpha: 0.6)
        : c.backgroundPrimary.withValues(alpha: 0.9);

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final slide = _controller.value * 2 - 1;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(-1.0 + slide * 2, -0.3),
            end: Alignment(1.0 + slide * 2, 0.3),
            colors: [base, highlight, base],
            stops: const [0.1, 0.5, 0.9],
          ).createShader(bounds),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// Basic shimmer placeholder box.
class AppShimmerBox extends StatelessWidget {
  const AppShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
    this.isCircle = false,
  });

  final double width;
  final double height;
  final double radius;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: c.surface,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(radius),
      ),
    );
  }
}

// Shimmer skeleton matching a project card.
class ProjectCardShimmer extends StatelessWidget {
  const ProjectCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppShimmer(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.backgroundPrimary,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppShimmerBox(width: 44, height: 44, radius: 12),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmerBox(width: 90, height: 18, radius: 99),
                      SizedBox(height: 8),
                      AppShimmerBox(width: 180, height: 16),
                    ],
                  ),
                ),
                AppShimmerBox(width: 56, height: 28, radius: 99),
              ],
            ),
            SizedBox(height: 12),
            AppShimmerBox(width: double.infinity, height: 12),
            SizedBox(height: 6),
            AppShimmerBox(width: 220, height: 12),
            SizedBox(height: 12),
            AppShimmerBox(width: double.infinity, height: 34, radius: 10),
            SizedBox(height: 12),
            Row(
              children: [
                AppShimmerBox(width: 68, height: 28, radius: 99),
                SizedBox(width: 8),
                AppShimmerBox(width: 58, height: 28, radius: 99),
                SizedBox(width: 8),
                AppShimmerBox(width: 74, height: 28, radius: 99),
              ],
            ),
            SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppShimmerBox(width: 110, height: 14),
                AppShimmerBox(width: 92, height: 36, radius: 10),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Shimmer skeleton matching a developer card.
class DeveloperCardShimmer extends StatelessWidget {
  const DeveloperCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppShimmer(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.backgroundPrimary,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppShimmerBox(width: 52, height: 52, isCircle: true),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmerBox(width: 140, height: 16),
                      SizedBox(height: 8),
                      AppShimmerBox(width: 110, height: 12),
                    ],
                  ),
                ),
                AppShimmerBox(width: 36, height: 36, radius: 10),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                AppShimmerBox(width: 64, height: 28, radius: 99),
                SizedBox(width: 8),
                AppShimmerBox(width: 56, height: 28, radius: 99),
                SizedBox(width: 8),
                AppShimmerBox(width: 72, height: 28, radius: 99),
              ],
            ),
            SizedBox(height: 12),
            AppShimmerBox(width: double.infinity, height: 42, radius: 12),
            SizedBox(height: 14),
            AppShimmerBox(width: double.infinity, height: 44, radius: 12),
          ],
        ),
      ),
    );
  }
}
