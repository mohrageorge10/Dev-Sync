import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Circular progress header card showing overall profile completion.
class CompletionProgressCard extends StatelessWidget {
  const CompletionProgressCard({
    super.key,
    required this.completion,
    required this.missingCount,
  });

  final int completion;
  final int missingCount;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final done = completion == 100;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [c.backgroundPrimary, c.subtleBlueSurface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: c.border),
      ),
      child: Column(
        children: [
          Text(
            'A complete profile gives you more accurate project matches.',
            textAlign: TextAlign.center,
            style: AppStyles.body12Secondary(context),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: completion / 100,
                    strokeWidth: 9,
                    color: c.primary,
                    backgroundColor: c.border,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('$completion%', style: AppStyles.h28(context)),
                    Text(
                      'COMPLETED',
                      style: AppStyles.overline9Secondary(
                        context,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: c.backgroundPrimary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  done ? Icons.verified : Icons.add_task,
                  size: 13,
                  color: done ? c.success : c.primary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    done
                        ? 'Top Match status unlocked'
                        : 'Add $missingCount more item${missingCount == 1 ? '' : 's'} to unlock Top Match status',
                    style: AppStyles.caption10Bold(
                      context,
                      color: done ? c.success : c.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
