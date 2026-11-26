import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import '../section_card.dart';
import '../section_title.dart';

// Card displaying the applicant's cover note.
class CoverNoteCard extends StatelessWidget {
  const CoverNoteCard({super.key, required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Cover Note'),
          Text(
            note,
            style: AppStyles.body13Secondary(
              context,
            ).copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
