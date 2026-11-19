import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Dashed border card for adding a custom skill.
class DashedAddSkillChip extends StatelessWidget {
  const DashedAddSkillChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRRectPainter(color: c.primary),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: c.subtleBlueSurface.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: c.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.add_rounded, size: 14, color: c.onPrimary),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Add "$label"',
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.body13Bold(context, color: c.primary),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.add_rounded, size: 16, color: c.primary),
            ],
          ),
        ),
      ),
    );
  }
}

// Dashed rounded rectangle border painter.
class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    ).deflate(0.7);

    final dashed = Path();
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 8.5) {
        dashed.addPath(
          metric.extractPath(d, (d + 5).clamp(0.0, metric.length)),
          Offset.zero,
        );
      }
    }
    canvas.drawPath(dashed, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) => old.color != color;
}
