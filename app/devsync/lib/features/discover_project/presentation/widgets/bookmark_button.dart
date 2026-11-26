import 'package:devsync/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Reusable square bookmark button.
class BookmarkButton extends StatelessWidget {
  const BookmarkButton({
    super.key,
    this.isSaved = false,
    this.onTap,
    this.size = 40,
  });

  final bool isSaved;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: c.subtleBlueSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: isSaved ? c.primary : c.textSecondary,
          size: size * 0.5,
        ),
      ),
    );
  }
}