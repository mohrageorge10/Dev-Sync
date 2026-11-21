import 'package:flutter/material.dart';
import 'package:devsync/core/theme/app_colors.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? footer;
  final List<Widget>? actions;
  final bool showBack;
  const AppScaffold({super.key, required this.title, required this.child, this.footer, this.actions, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: c.backgroundPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: c.textPrimary,
        titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.textPrimary),
        automaticallyImplyLeading: false,
        leading: showBack && Navigator.canPop(context)
            ? IconButton(icon: const Icon(Icons.arrow_back, size: 20), onPressed: () => Navigator.maybePop(context))
            : null,
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), child: child)),
          if (footer != null)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: BoxDecoration(color: c.backgroundPrimary, border: Border(top: BorderSide(color: c.border))),
              child: footer,
            ),
        ]),
      ),
    );
  }
}
