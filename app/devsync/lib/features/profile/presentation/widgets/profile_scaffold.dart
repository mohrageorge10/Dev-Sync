import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:flutter/material.dart';

// Shared scrollable scaffold with optional sticky footer for profile screens.
class ProfileScaffold extends StatelessWidget {
  const ProfileScaffold({
    super.key,
    required this.title,
    required this.child,
    this.footer,
    this.actions,
    this.showBack = true,
  });

  final String title;
  final Widget child;
  final Widget? footer;
  final List<Widget>? actions;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: c.backgroundPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: c.textPrimary,
        titleTextStyle: AppStyles.title16Bold(context),
        automaticallyImplyLeading: false,
        leading: showBack && Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: child,
              ),
            ),
            if (footer != null)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: BoxDecoration(
                  color: c.backgroundPrimary,
                  border: Border(top: BorderSide(color: c.border)),
                ),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}
