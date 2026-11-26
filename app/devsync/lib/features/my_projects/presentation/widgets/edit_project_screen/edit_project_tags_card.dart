import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../section_card.dart';
import '../section_title.dart';

// Card for adding and removing project tech stack tags.
class EditProjectTagsCard extends StatelessWidget {
  const EditProjectTagsCard({
    super.key,
    required this.controller,
    required this.tags,
    required this.onAdd,
    required this.onRemoveAt,
  });

  final TextEditingController controller;
  final List<String> tags;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemoveAt;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Tech Stack & Tags'),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: AppStyles.body13Primary(context),
                  onSubmitted: (_) => onAdd(),
                  decoration: InputDecoration(
                    hintText: 'Add skill or tag (e.g. Flutter, Go)...',
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
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var i = 0; i < tags.length; i++)
                  InputChip(
                    label: Text(
                      tags[i],
                      style: AppStyles.body12Medium(context, color: c.primary),
                    ),
                    backgroundColor: c.subtleBlueSurface,
                    side: BorderSide.none,
                    deleteIconColor: c.primary,
                    onDeleted: () => onRemoveAt(i),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
