import 'package:flutter/material.dart';
import 'package:devsync/core/theme/app_colors.dart';

class DashedBox extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const DashedBox({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashPainter(borderColor: context.colors.border),
        child: InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12), child: SizedBox(width: double.infinity, child: child))),
      );
}

class _DashPainter extends CustomPainter {
  final Color borderColor;
  _DashPainter({required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)));
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
        d += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.borderColor != borderColor;
}
