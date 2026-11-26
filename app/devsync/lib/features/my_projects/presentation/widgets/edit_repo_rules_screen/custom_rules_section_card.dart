import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../section_card.dart';
import '../section_title.dart';

// Card for adding and removing custom project contribution rules.
class CustomRulesSectionCard extends StatelessWidget {
  const CustomRulesSectionCard({
    super.key,
    required this.controller,
    required this.rules,
    required this.onAdd,
    required this.onRemoveAt,
  });

  final TextEditingController controller;
  final List<String> rules;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemoveAt;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Custom Rules'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: AppStyles.body13Primary(context),
                  onSubmitted: (_) => onAdd(),
                  decoration: InputDecoration(
                    hintText: 'e.g. Run dart analyze before PR...',
                    hintStyle: AppStyles.body12Secondary(context),
                    filled: true,
                    fillColor: c.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: c.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: c.border),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onAdd,
                style: IconButton.styleFrom(
                  backgroundColor: c.subtleBlueSurface,
                  foregroundColor: c.primary,
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
              ),
            ],
          ),
          if (rules.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (var i = 0; i < rules.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 15,
                      color: c.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rules[i],
                        style: AppStyles.body12Primary(context),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: c.textSecondary,
                      ),
                      onPressed: () => onRemoveAt(i),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
