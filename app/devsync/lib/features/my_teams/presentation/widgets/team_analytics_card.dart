import 'dart:math' as math;

import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/my_teams/data/models/models.dart';
import 'package:devsync/features/my_teams/presentation/widgets/common.dart';
import 'package:flutter/material.dart';

// Visual project analytics card with status donut chart, KPIs, and member workload bars.
class TeamAnalyticsCard extends StatelessWidget {
  const TeamAnalyticsCard({
    super.key,
    required this.breakdown,
    required this.overdueCount,
    required this.workload,
  });

  final Map<TaskStatus, int> breakdown;
  final int overdueCount;
  final List<({Member member, int done, int total})> workload;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final todo = breakdown[TaskStatus.todo] ?? 0;
    final inProgress = breakdown[TaskStatus.inProgress] ?? 0;
    final inReview = breakdown[TaskStatus.inReview] ?? 0;
    final done = breakdown[TaskStatus.done] ?? 0;
    final total = todo + inProgress + inReview + done;
    final pct = total == 0 ? 0 : (done * 100 / total).round();

    final segments = [
      _DonutSegment(value: done, color: c.success, label: 'Done'),
      _DonutSegment(value: inReview, color: c.warning, label: 'In Review'),
      _DonutSegment(value: inProgress, color: c.primary, label: 'In Progress'),
      _DonutSegment(
        value: todo,
        color: c.textSecondary.withValues(alpha: 0.35),
        label: 'To Do',
      ),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_rounded, size: 17, color: c.primary),
              const SizedBox(width: 6),
              Text('Project Analytics', style: AppStyles.body14Bold(context)),
              const Spacer(),
              Text(
                '$total tasks',
                style: AppStyles.body11Secondary(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Donut chart + legend.
          Row(
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(96, 96),
                      painter: _DonutPainter(
                        segments: segments,
                        trackColor: c.border,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('$pct%', style: AppStyles.title16Bold(context)),
                        Text(
                          'Done',
                          style: AppStyles.body11Secondary(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    for (final s in segments)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: s.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                s.label,
                                style: AppStyles.body12Secondary(context),
                              ),
                            ),
                            Text(
                              '${s.value}',
                              style: AppStyles.body12Bold(context),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Compact 3-KPI strip.
          Row(
            children: [
              Expanded(
                child: _KpiTile(
                  label: 'Completed',
                  value: '$done',
                  color: c.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KpiTile(
                  label: 'In Review',
                  value: '$inReview',
                  color: c.warning,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _KpiTile(
                  label: 'Overdue',
                  value: '$overdueCount',
                  color: overdueCount > 0 ? c.error : c.textSecondary,
                ),
              ),
            ],
          ),

          if (workload.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: c.border),
            const SizedBox(height: 12),
            Text('Team Workload', style: AppStyles.body12Bold(context)),
            const SizedBox(height: 10),
            for (final item in workload) ...[
              _WorkloadRow(
                member: item.member,
                done: item.done,
                total: item.total,
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _DonutSegment {
  const _DonutSegment({
    required this.value,
    required this.color,
    required this.label,
  });

  final int value;
  final Color color;
  final String label;
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.segments, required this.trackColor});

  final List<_DonutSegment> segments;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<int>(0, (sum, s) => sum + s.value);
    const strokeWidth = 10.0;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = trackColor;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    if (total == 0) return;

    var startAngle = -math.pi / 2;
    const gap = 0.04;
    final nonZero = segments.where((s) => s.value > 0).length;

    for (final seg in segments) {
      if (seg.value <= 0) continue;
      final sweep = (seg.value / total) * math.pi * 2;
      final adjustedSweep = nonZero > 1 ? (sweep - gap).clamp(0.05, sweep) : sweep;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..color = seg.color;
      canvas.drawArc(rect, startAngle, adjustedSweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.segments != segments || oldDelegate.trackColor != trackColor;
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Text(value, style: AppStyles.title15Bold(context, color: color)),
          const SizedBox(height: 2),
          Text(label, style: AppStyles.body11Secondary(context)),
        ],
      ),
    );
  }
}

class _WorkloadRow extends StatelessWidget {
  const _WorkloadRow({
    required this.member,
    required this.done,
    required this.total,
  });

  final Member member;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ratio = total == 0 ? 0.0 : done / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Avatar(member.initials, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                member.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyles.body12Primary(context),
              ),
            ),
            Text(
              '$done/$total done',
              style: AppStyles.body11Secondary(context),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: c.surface,
            valueColor: AlwaysStoppedAnimation(
              ratio >= 1.0 && total > 0 ? c.success : c.primary,
            ),
          ),
        ),
      ],
    );
  }
}
