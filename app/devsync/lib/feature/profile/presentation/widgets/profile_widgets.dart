library;

// ── Core Theme & Shared Widgets
export 'package:devsync/core/theme/app_colors.dart';
export 'package:devsync/core/theme/app_styles.dart';
export 'package:devsync/core/shared/badges/app_badge.dart';
export 'package:devsync/core/shared/buttons/app_primary_button.dart';
export 'package:devsync/core/shared/buttons/app_secondary_button.dart';
export 'package:devsync/core/shared/buttons/app_text_button.dart';
export 'package:devsync/core/shared/cards/app_developer_card.dart';
export 'package:devsync/core/shared/cards/app_project_card.dart';
export 'package:devsync/core/shared/chips/app_skill_chip.dart';
export 'package:devsync/core/shared/input_fields/app_input_field.dart';
export 'package:devsync/core/shared/selectors/app_dropdown_field.dart';
export 'package:devsync/core/shared/tap_bars/app_segmented_control.dart';
export 'package:devsync/core/shared/tap_bars/app_tab_bar.dart';

// ── Profile-specific widgets
export 'buttons/profile_primary_button.dart';
export 'buttons/profile_soft_button.dart';
export 'buttons/profile_compact_button.dart';
export 'cards/profile_card.dart';
export 'cards/profile_dashed_box.dart';
export 'badges/profile_tag.dart';
export 'chips/profile_select_chip.dart';
export 'tap_bars/profile_segmented_bar.dart';
export 'input_fields/profile_field_label.dart';
export 'input_fields/field_decoration.dart';
export 'layout/profile_scaffold.dart';
export 'layout/profile_step_progress.dart';
export 'layout/profile_step_footer.dart';
export 'layout/profile_section_label.dart';
export 'layout/profile_screen_title.dart';
export 'profile_flow.dart';

import 'package:flutter/material.dart';
import 'package:devsync/core/theme/app_styles.dart';

/// ألوان الـ Profile — نفس قيم AppColors.light بالظبط كـ const literals.
/// (Dart لا يسمح بـ const access على instance fields حتى لو الـ instance نفسه const)
class ProfileColors {
  ProfileColors._();
  static const primary           = Color(0xFF315BDB);
  static const primaryPressed    = Color(0xFF2548B8);
  static const darkBlueAccent    = Color(0xFF173B9A);
  static const onPrimary         = Color(0xFFFFFFFF);
  static const backgroundPrimary = Color(0xFFFFFFFF);
  static const surface           = Color(0xFFF5F7FC);
  static const secondarySurface  = Color(0xFFF5F7FC);
  static const subtleBlueSurface = Color(0xFFEEF3FF);
  static const textPrimary       = Color(0xFF17233D);
  static const textSecondary     = Color(0xFF65718A);
  static const border            = Color(0xFFDDE4F2);
  static const success           = Color(0xFF16845B);
  static const warning           = Color(0xFFA86512);
  static const error             = Color(0xFFC43D4B);
  static const successSoft       = Color(0x2916845B);
  static const errorSoft         = Color(0x1AC43D4B);
}

/// ستايلات النصوص — مطابقة لـ ProfileStyles في المشروع الأصلي
class ProfileStyles {
  ProfileStyles._();
  static const caption           = TextStyle(fontSize: 10, color: ProfileColors.textSecondary);
  static const bodySmall         = TextStyle(fontSize: 11, color: ProfileColors.textSecondary);
  static const cardTitle         = TextStyle(fontSize: 12, fontWeight: FontWeight.w800);
  static const subtitle          = TextStyle(fontSize: 12, color: ProfileColors.textSecondary, height: 1.4);
  static const cardTitleLarge    = TextStyle(fontSize: 13, fontWeight: FontWeight.w800);
  static const body              = TextStyle(fontSize: 12, color: ProfileColors.textSecondary);
  static const title             = AppStyles.primary_28_700;
  static const bodySmallRelaxed  = TextStyle(fontSize: 11, color: ProfileColors.textSecondary, height: 1.4);
  static const input             = TextStyle(fontSize: 12);
  static const sectionTitle      = TextStyle(fontSize: 14, fontWeight: FontWeight.w800);
  static const heading           = TextStyle(fontSize: 16, fontWeight: FontWeight.w800);
}
