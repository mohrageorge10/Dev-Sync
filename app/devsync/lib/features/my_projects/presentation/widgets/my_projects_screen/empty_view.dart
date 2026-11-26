import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Empty state message displayed when a project tab has no items.
class EmptyView extends StatelessWidget {
  const EmptyView(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: AppStyles.body13Secondary(context)),
    );
  }
}
