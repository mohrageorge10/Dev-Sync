import 'package:flutter/material.dart';
import 'package:devsync/core/theme/app_colors.dart';

class StepProgress extends StatelessWidget {
  final int percent;
  const StepProgress(this.percent, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text('$percent% completed', style: TextStyle(fontSize: 11, color: c.textSecondary)),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(value: percent / 100, minHeight: 5, backgroundColor: c.border, color: c.primary),
      ),
      const SizedBox(height: 18),
    ]);
  }
}
