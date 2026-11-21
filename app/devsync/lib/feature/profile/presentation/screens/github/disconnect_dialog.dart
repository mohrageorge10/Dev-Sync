import 'package:flutter/material.dart';
import '../../widgets/profile_widgets.dart';

/// Returns true if the user confirmed.
Future<bool> showDisconnectGithubDialog(BuildContext context, {required int keptSkills}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: ProfileColors.errorSoft, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.link_off, color: ProfileColors.error),
          ),
          const SizedBox(height: 12),
          const Text('Disconnect GitHub?', style: ProfileStyles.heading),
          const SizedBox(height: 6),
          const Text('Your analysis data will be removed. Skills you added stay on your profile.',
              style: ProfileStyles.subtitle),
          if (keptSkills > 0) ...[
            const SizedBox(height: 10),
            AppCard(
              color: ProfileColors.subtleBlueSurface,
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                const Icon(Icons.verified, size: 16, color: ProfileColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text('$keptSkills skills already added will remain verified on your developer profile.', style: const TextStyle(fontSize: 11))),
              ]),
            ),
          ],
          const SizedBox(height: 16),
          PrimaryButton('Disconnect', icon: Icons.delete_outline, color: ProfileColors.error, onPressed: () => Navigator.pop(context, true)),
          const SizedBox(height: 8),
          SoftButton('Cancel', onPressed: () => Navigator.pop(context, false)),
        ]),
      ),
    ),
  );
  return r ?? false;
}
