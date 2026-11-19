import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/features/create_project/presentation/widgets/builder_picker_sheet.dart';
import 'package:devsync/features/create_project/presentation/widgets/soft_card.dart';
import 'package:flutter/material.dart';

// Card to search and invite registered developers.
class InviteCard extends StatefulWidget {
  const InviteCard({super.key});

  @override
  State<InviteCard> createState() => _InviteCardState();
}

class _InviteCardState extends State<InviteCard> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _openSearch() => BuilderPickerSheet.show(
        context,
        initialQuery: _c.text.trim().replaceFirst('@', ''),
      );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_search_outlined, size: 18, color: c.primary),
              const SizedBox(width: 8),
              Text(
                'Invite registered developers',
                style: AppStyles.label14SemiBold(context),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Search registered users by @publicId, name, track, or skill.',
            style: AppStyles.body11Secondary(context),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: AppInputField(
                  controller: _c,
                  hint: 'Search @publicId, name, or skill...',
                  prefixIcon: Icons.alternate_email_rounded,
                  onSubmitted: (_) => _openSearch(),
                ),
              ),
              const SizedBox(width: 8),
              AppPrimaryButton(
                buttonText: 'Find',
                isDisabled: false,
                onPressed: _openSearch,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
