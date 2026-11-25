import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Dashed border drop/tap zone used for résumé uploads.
class ProfileDashedBox extends StatelessWidget {
  const ProfileDashedBox({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashPainter(borderColor: context.colors.border),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  _DashPainter({required this.borderColor});

  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      );
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter oldDelegate) =>
      oldDelegate.borderColor != borderColor;
}
