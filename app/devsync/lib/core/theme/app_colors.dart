import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.surfacePrimary,
    required this.surfaceSecondary,
    required this.surfaceTertiary,
    required this.surfaceElevated,
    required this.surfaceBrand,
    required this.surfaceDisabled,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textInverse,
    required this.textBrand,
    required this.textLink,
    required this.iconPrimary,
    required this.iconSecondary,
    required this.iconDisabled,
    required this.iconBrand,
    required this.iconInverse,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderBrand,
    required this.borderDisabled,
    required this.dividerDefault,
    required this.buttonPrimaryBackground,
    required this.buttonPrimaryForeground,
    required this.buttonSecondaryBackground,
    required this.buttonSecondaryForeground,
    required this.feedbackSuccessBackground,
    required this.feedbackSuccessForeground,
    required this.feedbackErrorBackground,
    required this.feedbackErrorForeground,
    required this.feedbackWarningBackground,
    required this.feedbackWarningForeground,
    required this.feedbackInfoBackground,
    required this.feedbackInfoForeground,
    required this.badgeNeutralBackground,
    required this.badgeNeutralForeground,
    required this.selectionBackground,
    required this.selectionForeground,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.chartPrimary,
    required this.chartSecondary,
    required this.chartTertiary,
  });

  // ---------------------------------------------------------------------------
  // Brand palette (same in light and dark)
  // ---------------------------------------------------------------------------
  static const Color brand50 = Color(0xFFF3EEFF);
  static const Color brand100 = Color(0xFFE5D9FF);
  static const Color brand200 = Color(0xFFCDB8FF);
  static const Color brand300 = Color(0xFFB294FF);   // AppColors.brand50
  static const Color brand400 = Color(0xFF9568FF);
  static const Color brand500 = Color(0xFF7537FC);
  static const Color brand600 = Color(0xFF6425E8);
  static const Color brand700 = Color(0xFF511BC5);
  static const Color brand800 = Color(0xFF3F1697);
  static const Color brand900 = Color(0xFF2D1268);

  // ---------------------------------------------------------------------------
  // Semantic tokens (theme-aware)
  // ---------------------------------------------------------------------------
  // background
  final Color backgroundPrimary;
  final Color backgroundSecondary;
  // surface
  final Color surfacePrimary;
  final Color surfaceSecondary;
  final Color surfaceTertiary;
  final Color surfaceElevated;
  final Color surfaceBrand;
  final Color surfaceDisabled;
  // text
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color textInverse;
  final Color textBrand;
  final Color textLink;
  // icon
  final Color iconPrimary;
  final Color iconSecondary;
  final Color iconDisabled;
  final Color iconBrand;
  final Color iconInverse;
  // border
  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;
  final Color borderBrand;
  final Color borderDisabled;
  // divider
  final Color dividerDefault;
  // button
  final Color buttonPrimaryBackground;
  final Color buttonPrimaryForeground;
  final Color buttonSecondaryBackground;
  final Color buttonSecondaryForeground;
  // feedback
  final Color feedbackSuccessBackground;
  final Color feedbackSuccessForeground;
  final Color feedbackErrorBackground;
  final Color feedbackErrorForeground;
  final Color feedbackWarningBackground;
  final Color feedbackWarningForeground;
  final Color feedbackInfoBackground;
  final Color feedbackInfoForeground;    
  // badge
  final Color badgeNeutralBackground;
  final Color badgeNeutralForeground;
  // selection
  final Color selectionBackground;
  final Color selectionForeground;
  // skeleton
  final Color skeletonBase;
  final Color skeletonHighlight;
  // chart
  final Color chartPrimary;
  final Color chartSecondary;
  final Color chartTertiary;

  static const AppColors light = AppColors(
    // background
    backgroundPrimary: Color(0xFFFFFFFF),
    backgroundSecondary: Color(0xFFF8F7FC),
    // surface
    surfacePrimary: Color(0xFFFFFFFF),
    surfaceSecondary: Color(0xFFF3F0FA),
    surfaceTertiary: Color(0xFFEAE5F3),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceBrand: Color(0xFFF3EEFF),
    surfaceDisabled: Color(0xFFF1EFF5),
    // text
    textPrimary: Color(0xFF171321),
    textSecondary: Color(0xFF625B71),
    textTertiary: Color(0xFF898296), // context.colors.textTertiary
    textDisabled: Color(0xFFB7B2C2),
    textInverse: Color(0xFFFFFFFF),
    textBrand: Color(0xFF6425E8),
    textLink: Color(0xFF6425E8),
    // icon
    iconPrimary: Color(0xFF292335),
    iconSecondary: Color(0xFF777084),
    iconDisabled: Color(0xFFB7B2C2),
    iconBrand: Color(0xFF7537FC),
    iconInverse: Color(0xFFFFFFFF),
    // border
    borderSubtle: Color(0xFFF0ECF6),
    borderDefault: Color(0xFFE4DFED),
    borderStrong: Color(0xFFC9C1D8),
    borderBrand: Color(0xFF7537FC),
    borderDisabled: Color(0xFFEAE7F0),
    // divider
    dividerDefault: Color(0xFFEAE5F1),
    // button
    buttonPrimaryBackground: Color(0xFF7537FC),
    buttonPrimaryForeground: Color(0xFFFFFFFF),
    buttonSecondaryBackground: Color(0xFFF5F0FF),
    buttonSecondaryForeground: Color(0xFF4A484D),
    // feedback
    feedbackSuccessBackground: Color(0xFFE8F8EF),
    feedbackSuccessForeground: Color(0xFF166534),
    feedbackErrorBackground: Color(0xFFFFF0F2),
    feedbackErrorForeground: Color(0xFFB4233A),
    feedbackWarningBackground: Color(0xFFFFF5DF),
    feedbackWarningForeground: Color(0xFF854D0E),
    feedbackInfoBackground: Color(0xFFEBF3FF),
    feedbackInfoForeground: Color(0xFF1D4ED8),
    // badge
    badgeNeutralBackground: Color(0xFFF1EEF6),
    badgeNeutralForeground: Color(0xFF625B71),
    // selection
    selectionBackground: Color(0xFFE9DEFF),
    selectionForeground: Color(0xFF511BC5),
    // skeleton
    skeletonBase: Color(0xFFEAE5F1),
    skeletonHighlight: Color(0xFFF7F4FB),
    // chart
    chartPrimary: Color(0xFF7537FC),
    chartSecondary: Color(0xFF9B7AFB),
    chartTertiary: Color(0xFFC1AEFF),
  );

  static const AppColors dark = AppColors(
    // background
    backgroundPrimary: Color(0xFF100D18),
    backgroundSecondary: Color(0xFF15111F),
    // surface
    surfacePrimary: Color(0xFF191522),
    surfaceSecondary: Color(0xFF211B2D),
    surfaceTertiary: Color(0xFF292236),
    surfaceElevated: Color(0xFF262033),
    surfaceBrand: Color(0xFF2B1D49),
    surfaceDisabled: Color(0xFF211D29),
    // text
    textPrimary: Color(0xFFF7F4FF),
    textSecondary: Color(0xFFC2BBD1),
    textTertiary: Color(0xFF9289A6),
    textDisabled: Color(0xFF696174),
    textInverse: Color(0xFF171321),
    textBrand: Color(0xFFB69AFF),
    textLink: Color(0xFFB69AFF),
    // icon
    iconPrimary: Color(0xFFF0EAFB),
    iconSecondary: Color(0xFFAAA1BB),
    iconDisabled: Color(0xFF696174),
    iconBrand: Color(0xFFB69AFF),
    iconInverse: Color(0xFF171321),
    // border
    borderSubtle: Color(0xFF2A2436),
    borderDefault: Color(0xFF393146),
    borderStrong: Color(0xFF514660),
    borderBrand: Color(0xFF9568FF),
    borderDisabled: Color(0xFF302A3A),
    // divider
    dividerDefault: Color(0xFF332C40),
    // button
    buttonPrimaryBackground: Color(0xFF7537FC),
    buttonPrimaryForeground: Color(0xFFFFFFFF),
    buttonSecondaryBackground: Color(0xFF1E1E1E),
    buttonSecondaryForeground: Color(0xFFFDFDFD),
    // feedback
    feedbackSuccessBackground: Color(0xFF153524),
    feedbackSuccessForeground: Color(0xFF8CE8AE),
    feedbackErrorBackground: Color(0xFF3A1B24),
    feedbackErrorForeground: Color(0xFFFF9CAA),
    feedbackWarningBackground: Color(0xFF392A13),
    feedbackWarningForeground: Color(0xFFFFD27A),
    feedbackInfoBackground: Color(0xFF192B45),
    feedbackInfoForeground: Color(0xFF9BC5FF),
    // badge
    badgeNeutralBackground: Color(0xFF302A3A),
    badgeNeutralForeground: Color(0xFFD0C9DE),
    // selection
    selectionBackground: Color(0xFF39285C),
    selectionForeground: Color(0xFFD0BFFF),
    // skeleton
    skeletonBase: Color(0xFF2B2536),
    skeletonHighlight: Color(0xFF393146),
    // chart
    chartPrimary: Color(0xFFB69AFF),
    chartSecondary: Color(0xFF8A68E8),
    chartTertiary: Color(0xFF684CB5),
  );

  @override
  AppColors copyWith({
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? surfacePrimary,
    Color? surfaceSecondary,
    Color? surfaceTertiary,
    Color? surfaceElevated,
    Color? surfaceBrand,
    Color? surfaceDisabled,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textInverse,
    Color? textBrand,
    Color? textLink,
    Color? iconPrimary,
    Color? iconSecondary,
    Color? iconDisabled,
    Color? iconBrand,
    Color? iconInverse,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderBrand,
    Color? borderDisabled,
    Color? dividerDefault,
    Color? buttonPrimaryBackground,
    Color? buttonPrimaryForeground,
    Color? buttonSecondaryBackground,
    Color? buttonSecondaryForeground,
    Color? feedbackSuccessBackground,
    Color? feedbackSuccessForeground,
    Color? feedbackErrorBackground,
    Color? feedbackErrorForeground,
    Color? feedbackWarningBackground,
    Color? feedbackWarningForeground,
    Color? feedbackInfoBackground,
    Color? feedbackInfoForeground,
    Color? badgeNeutralBackground,
    Color? badgeNeutralForeground,
    Color? selectionBackground,
    Color? selectionForeground,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? chartPrimary,
    Color? chartSecondary,
    Color? chartTertiary,
  }) {
    return AppColors(
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      surfaceTertiary: surfaceTertiary ?? this.surfaceTertiary,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceBrand: surfaceBrand ?? this.surfaceBrand,
      surfaceDisabled: surfaceDisabled ?? this.surfaceDisabled,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textInverse: textInverse ?? this.textInverse,
      textBrand: textBrand ?? this.textBrand,
      textLink: textLink ?? this.textLink,
      iconPrimary: iconPrimary ?? this.iconPrimary,
      iconSecondary: iconSecondary ?? this.iconSecondary,
      iconDisabled: iconDisabled ?? this.iconDisabled,
      iconBrand: iconBrand ?? this.iconBrand,
      iconInverse: iconInverse ?? this.iconInverse,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderBrand: borderBrand ?? this.borderBrand,
      borderDisabled: borderDisabled ?? this.borderDisabled,
      dividerDefault: dividerDefault ?? this.dividerDefault,
      buttonPrimaryBackground: buttonPrimaryBackground ?? this.buttonPrimaryBackground,
      buttonPrimaryForeground: buttonPrimaryForeground ?? this.buttonPrimaryForeground,
      buttonSecondaryBackground: buttonSecondaryBackground ?? this.buttonSecondaryBackground,
      buttonSecondaryForeground: buttonSecondaryForeground ?? this.buttonSecondaryForeground,
      feedbackSuccessBackground: feedbackSuccessBackground ?? this.feedbackSuccessBackground,
      feedbackSuccessForeground: feedbackSuccessForeground ?? this.feedbackSuccessForeground,
      feedbackErrorBackground: feedbackErrorBackground ?? this.feedbackErrorBackground,
      feedbackErrorForeground: feedbackErrorForeground ?? this.feedbackErrorForeground,
      feedbackWarningBackground: feedbackWarningBackground ?? this.feedbackWarningBackground,
      feedbackWarningForeground: feedbackWarningForeground ?? this.feedbackWarningForeground,
      feedbackInfoBackground: feedbackInfoBackground ?? this.feedbackInfoBackground,
      feedbackInfoForeground: feedbackInfoForeground ?? this.feedbackInfoForeground,
      badgeNeutralBackground: badgeNeutralBackground ?? this.badgeNeutralBackground,
      badgeNeutralForeground: badgeNeutralForeground ?? this.badgeNeutralForeground,
      selectionBackground: selectionBackground ?? this.selectionBackground,
      selectionForeground: selectionForeground ?? this.selectionForeground,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      chartPrimary: chartPrimary ?? this.chartPrimary,
      chartSecondary: chartSecondary ?? this.chartSecondary,
      chartTertiary: chartTertiary ?? this.chartTertiary,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      backgroundPrimary: Color.lerp(backgroundPrimary, other.backgroundPrimary, t)!,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      surfacePrimary: Color.lerp(surfacePrimary, other.surfacePrimary, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      surfaceTertiary: Color.lerp(surfaceTertiary, other.surfaceTertiary, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceBrand: Color.lerp(surfaceBrand, other.surfaceBrand, t)!,
      surfaceDisabled: Color.lerp(surfaceDisabled, other.surfaceDisabled, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      textBrand: Color.lerp(textBrand, other.textBrand, t)!,
      textLink: Color.lerp(textLink, other.textLink, t)!,
      iconPrimary: Color.lerp(iconPrimary, other.iconPrimary, t)!,
      iconSecondary: Color.lerp(iconSecondary, other.iconSecondary, t)!,
      iconDisabled: Color.lerp(iconDisabled, other.iconDisabled, t)!,
      iconBrand: Color.lerp(iconBrand, other.iconBrand, t)!,
      iconInverse: Color.lerp(iconInverse, other.iconInverse, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderBrand: Color.lerp(borderBrand, other.borderBrand, t)!,
      borderDisabled: Color.lerp(borderDisabled, other.borderDisabled, t)!,
      dividerDefault: Color.lerp(dividerDefault, other.dividerDefault, t)!,
      buttonPrimaryBackground: Color.lerp(buttonPrimaryBackground, other.buttonPrimaryBackground, t)!,
      buttonPrimaryForeground: Color.lerp(buttonPrimaryForeground, other.buttonPrimaryForeground, t)!,
      buttonSecondaryBackground: Color.lerp(buttonSecondaryBackground, other.buttonSecondaryBackground, t)!,
      buttonSecondaryForeground: Color.lerp(buttonSecondaryForeground, other.buttonSecondaryForeground, t)!,
      feedbackSuccessBackground: Color.lerp(feedbackSuccessBackground, other.feedbackSuccessBackground, t)!,
      feedbackSuccessForeground: Color.lerp(feedbackSuccessForeground, other.feedbackSuccessForeground, t)!,
      feedbackErrorBackground: Color.lerp(feedbackErrorBackground, other.feedbackErrorBackground, t)!,
      feedbackErrorForeground: Color.lerp(feedbackErrorForeground, other.feedbackErrorForeground, t)!,
      feedbackWarningBackground: Color.lerp(feedbackWarningBackground, other.feedbackWarningBackground, t)!,
      feedbackWarningForeground: Color.lerp(feedbackWarningForeground, other.feedbackWarningForeground, t)!,
      feedbackInfoBackground: Color.lerp(feedbackInfoBackground, other.feedbackInfoBackground, t)!,
      feedbackInfoForeground: Color.lerp(feedbackInfoForeground, other.feedbackInfoForeground, t)!,
      badgeNeutralBackground: Color.lerp(badgeNeutralBackground, other.badgeNeutralBackground, t)!,
      badgeNeutralForeground: Color.lerp(badgeNeutralForeground, other.badgeNeutralForeground, t)!,
      selectionBackground: Color.lerp(selectionBackground, other.selectionBackground, t)!,
      selectionForeground: Color.lerp(selectionForeground, other.selectionForeground, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight: Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
      chartPrimary: Color.lerp(chartPrimary, other.chartPrimary, t)!,
      chartSecondary: Color.lerp(chartSecondary, other.chartSecondary, t)!,
      chartTertiary: Color.lerp(chartTertiary, other.chartTertiary, t)!,
    );
  }
}

/// Shortcut: `context.colors.textPrimary`
extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}