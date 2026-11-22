import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/feedback/app_feedback.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/core/theme/app_styles.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/ai_match/business_logic/match_actions_cubit.dart';
import 'package:devsync/features/ai_match/business_logic/match_actions_state.dart';
import 'package:devsync/features/ai_match/data/models/match_model.dart';
import 'package:devsync/features/ai_match/utils/ai_match_strings.dart';
import 'package:devsync/features/ai_match/widgets/match_score_ring.dart';
import 'package:devsync/features/ai_match/widgets/rate_recommendation_sheet.dart';
import 'package:devsync/features/auth/screens/login_required_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Texts that exist only in this screen's design.
const String _insightTag = 'AI MATCH INSIGHT';
const String _strengthTitle = 'RECOMMENDATION STRENGTH';
const String _verifiedMatch = 'Verified Match';
const String _valueAdd = 'Value-Add';
const String _mentored = 'Mentored';
const String _skillsToDevelop = 'Skills to Develop';
const String _complementaryHint =
    'Secondary proficiencies that elevate your code review speed and '
    'architectural stability.';
const String _complementaryNote =
    'These skills will help optimize the architecture and speed up issue '
    'triage.';
const String _developNote =
    'Not required immediately — the maintainers offer onboarding mentorship '
    'and pair programming sessions.';
const String _learnTitle = 'What you could learn';
const String _rateLabel = 'Rate';

// Icons of the "What you could learn" points (repeated if there are more).
const List<IconData> _learnIcons = [
  Icons.bluetooth_rounded,
  Icons.storage_rounded,
  Icons.hub_outlined,
];

/// Explains why the AI recommended one project.
/// Owns the [MatchActionsCubit] (save + join request) of this project.
class WhyThisFitsScreen extends StatelessWidget {
  const WhyThisFitsScreen({super.key, required this.match});

  final MatchModel match;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MatchActionsCubit>(
      create: (_) =>
          ServiceLocator.get<MatchActionsCubit>()..load(match.projectId),
      child: _WhyThisFitsView(match: match),
    );
  }
}

class _WhyThisFitsView extends StatefulWidget {
  const _WhyThisFitsView({required this.match});

  final MatchModel match;

  @override
  State<_WhyThisFitsView> createState() => _WhyThisFitsViewState();
}

class _WhyThisFitsViewState extends State<_WhyThisFitsView> {
  /// What the user rated (true = helpful), null = not rated yet.
  bool? _rated;

  MatchModel get match => widget.match;

  void _comingSoon(BuildContext context) => AppFeedback.show(
        context,
        message: AiMatchStrings.comingSoon,
        type: AppFeedbackType.info,
      );

  Future<void> _rate(BuildContext context, {bool? helpful}) async {
    final result = await showRateRecommendationSheet(context,
        match: match, initialHelpful: helpful);
    if (result != null && mounted) setState(() => _rated = result);
  }

  // No share package yet: copy a short text the user can paste anywhere.
  Future<void> _share(BuildContext context) async {
    await Clipboard.setData(ClipboardData(
      text: '${match.projectTitle} — ${match.score}% match for me on DevSync',
    ));
    if (!context.mounted) return;
    AppFeedback.show(
      context,
      message: AiMatchStrings.copiedMsg,
      type: AppFeedbackType.success,
    );
  }

  void _onEvent(BuildContext context, MatchActionEvent e) {
    switch (e.kind) {
      case MatchActionEventKind.needsLogin:
        showLoginRequiredSheet(context);
      case MatchActionEventKind.saved:
      case MatchActionEventKind.unsaved:
      case MatchActionEventKind.requestSent:
        AppFeedback.show(context,
            message: e.message, type: AppFeedbackType.success);
      case MatchActionEventKind.error:
        AppFeedback.show(context,
            message: e.message, type: AppFeedbackType.error);
    }
  }

  // Look of the "Request to Join" button for each request status.
  ({String label, IconData? lead, IconData? trail, bool filled, bool enabled})
      _joinUi(MatchActionsState s) {
    if (s.sendingRequest) {
      return (
        label: AiMatchStrings.requestSending,
        lead: null,
        trail: null,
        filled: true,
        enabled: false,
      );
    }
    return switch (s.request) {
      null => (
          label: AiMatchStrings.requestToJoin,
          lead: null,
          trail: Icons.arrow_forward_rounded,
          filled: true,
          enabled: true,
        ),
      RequestStatus.pending => (
          label: AiMatchStrings.requestSent,
          lead: Icons.check_rounded,
          trail: null,
          filled: false,
          enabled: false,
        ),
      RequestStatus.accepted => (
          label: AiMatchStrings.requestAccepted,
          lead: Icons.check_circle_outline_rounded,
          trail: null,
          filled: false,
          enabled: false,
        ),
      RequestStatus.rejected => (
          label: AiMatchStrings.requestDeclined,
          lead: Icons.block_rounded,
          trail: null,
          filled: false,
          enabled: false,
        ),
    };
  }

  // "Strong Fit" -> "High Confidence", ...
  String get _confidence => switch (match.fit) {
        MatchFit.strong => 'High Confidence',
        MatchFit.good => 'Medium Confidence',
        MatchFit.partial => 'Low Confidence',
      };

  // "EcoTrack Mobile: Carbon Analytics" -> "EcoTrack"
  String get _shortName =>
      match.projectTitle.split(RegExp(r'[:\s]')).first.trim();

  // Learn points: explicit list first, then the tips of the missing skills.
  List<String> get _learnPoints => match.learnPoints.isNotEmpty
      ? match.learnPoints
      : [
          for (final t in match.learningTips)
            if (t.tip.isNotEmpty) t.tip,
        ];

  // BLE / Bluetooth skills get the bluetooth icon, the rest a circle.
  IconData _skillIcon(String skill) =>
      RegExp(r'\b(ble|bluetooth)\b', caseSensitive: false).hasMatch(skill)
          ? Icons.bluetooth_rounded
          : Icons.circle_outlined;

  // "Alex Rivera (@rivera-dev)" -> bold name + regular handle.
  InlineSpan _maintainerSpan(BuildContext context) {
    final c = context.colors;
    final m = match.leadMaintainer;
    final i = m.indexOf(' (');
    final name = i == -1 ? m : m.substring(0, i);
    final handle = i == -1 ? '' : m.substring(i);
    return TextSpan(
      children: [
        const TextSpan(text: 'Lead Maintainer: '),
        TextSpan(
          text: name,
          style: TextStyle(fontWeight: FontWeight.w700, color: c.textPrimary),
        ),
        if (handle.isNotEmpty) TextSpan(text: handle),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // In the design a strong match is blue (not green).
    final isStrong = match.fit == MatchFit.strong;
    final fitColor = isStrong ? c.primary : matchFitColor(context, match.fit);
    // The ring picks its color from the fit: "good" = primary blue.
    final ringFit = isStrong ? MatchFit.good : match.fit;
    final isReal = match.purpose == ProjectPurpose.real;
    final purposeColor = isReal ? c.primary : c.success;
    final summary = match.matchedSkills.isEmpty
        ? ''
        : 'Your proficiency in ${match.matchedSkills.take(3).join(', ')} '
            'matches what this project needs.';
    final learn = _learnPoints;
    final timeAgo = _shortTimeAgo(match.createdAt);

    return BlocConsumer<MatchActionsCubit, MatchActionsState>(
      listenWhen: (prev, curr) =>
          curr.event != null && prev.event != curr.event,
      listener: (context, state) => _onEvent(context, state.event!),
      builder: (context, actions) {
        final join = _joinUi(actions);

        return Scaffold(
          backgroundColor: c.surface,
          appBar: AppBar(
            backgroundColor: c.backgroundPrimary,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: c.textPrimary),
              onPressed: () => Navigator.maybePop(context),
            ),
            title: Text(AiMatchStrings.whyTitle,
                style: AppStyles.title16Bold(context)),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_none_rounded,
                    color: c.textPrimary),
                onPressed: () => _comingSoon(context),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 16),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: c.primary,
                  child:
                      Icon(Icons.person_rounded, size: 16, color: c.onPrimary),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Tag row: AI MATCH INSIGHT • Sprint Cycle 14 ...... [bookmark][share]
              Row(
                children: [
                  _Tag(
                    label: _insightTag,
                    color: c.primary,
                    background: c.subtle(c.primary),
                  ),
                  if (match.sprintLabel.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        match.sprintLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.body11Secondary(context),
                      ),
                    ),
                  ],
                  const Spacer(),
                  _SquareIconButton(
                    icon: actions.saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    active: actions.saved,
                    onTap: () =>
                        context.read<MatchActionsCubit>().toggleSaved(match),
                  ),
                  const SizedBox(width: 6),
                  _SquareIconButton(
                    icon: Icons.share_outlined,
                    onTap: () => _share(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Project header
              _Card(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.border),
                      ),
                      child:
                          Icon(Icons.eco_rounded, size: 30, color: c.success),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: _Tag(
                                  label: isReal
                                      ? 'Real-world Project'
                                      : 'Learning Project',
                                  color: purposeColor,
                                  background: c.subtle(purposeColor),
                                ),
                              ),
                              const Spacer(),
                              if (timeAgo.isNotEmpty) ...[
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: c.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(timeAgo,
                                    style:
                                        AppStyles.caption10Secondary(context)),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(match.projectTitle,
                              style: AppStyles.title16Bold(context)),
                          if (match.leadMaintainer.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text.rich(
                              _maintainerSpan(context),
                              style: AppStyles.body11Secondary(context),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Recommendation strength
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(_strengthTitle,
                              style: AppStyles.overline9Bold(context,
                                  color: c.textSecondary)),
                        ),
                        _Tag(
                          label: _verifiedMatch,
                          color: c.primary,
                          background: c.subtle(c.primary),
                          icon: Icons.check_circle_outline_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.subtleBlueSurface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          MatchScoreRing(
                              score: match.score, fit: ringFit, size: 52),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: match.fitLabel,
                                        style: AppStyles.title15Bold(context,
                                            color: fitColor),
                                      ),
                                      TextSpan(
                                        text: '  •  $_confidence',
                                        style:
                                            AppStyles.body12Secondary(context),
                                      ),
                                    ],
                                  ),
                                ),
                                if (summary.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(summary,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          AppStyles.body12Secondary(context)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (match.explanation.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _InfoBox(
                        icon: Icons.person_pin_circle_outlined,
                        iconColor: c.primary,
                        background: c.primary.withValues(alpha: 0.12),
                        text: match.explanation,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Matched skills
              if (match.matchedSkills.isNotEmpty) ...[
                _Card(
                  title: AiMatchStrings.matchedSkills,
                  icon: Icons.check_circle_rounded,
                  iconColor: c.primary,
                  trailing: Text(
                    '${match.matchedSkills.length} of '
                    '${match.matchedSkills.length} verified',
                    style: AppStyles.body11Secondary(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Skills from your verified stack that directly solve '
                        '$_shortName issues:',
                        style: AppStyles.body12Secondary(context),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in match.matchedSkills)
                            _VerifiedChip(label: s),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Complementary skills
              if (match.complementarySkills.isNotEmpty) ...[
                _Card(
                  title: AiMatchStrings.complementarySkills,
                  icon: Icons.extension_outlined,
                  iconColor: c.primary,
                  iconBackground: c.subtle(c.primary),
                  trailing: Text(_valueAdd,
                      style: AppStyles.body12Bold(context, color: c.primary)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_complementaryHint,
                          style: AppStyles.body12Secondary(context)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in match.complementarySkills)
                            _PillChip(
                              label: s,
                              background: c.subtle(c.primary),
                              foreground: c.darkBlueAccent,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const _NoteRow(text: _complementaryNote),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Skills to develop
              if (match.missingSkills.isNotEmpty) ...[
                _Card(
                  title: _skillsToDevelop,
                  icon: Icons.trending_up_rounded,
                  iconColor: c.warning,
                  iconBackground: c.subtle(c.warning),
                  trailing: _Tag(
                    label: _mentored,
                    color: c.warning,
                    background: c.subtle(c.warning),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in match.missingSkills)
                            _PillChip(
                              label: s,
                              background: c.subtle(c.warning),
                              foreground: c.textPrimary,
                              icon: _skillIcon(s),
                              iconColor: c.warning,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InfoBox(
                        icon: Icons.school_outlined,
                        iconColor: c.textSecondary,
                        textColor: c.textSecondary,
                        text: _developNote,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // What you could learn
              if (learn.isNotEmpty) ...[
                _Card(
                  title: _learnTitle,
                  icon: Icons.auto_awesome_outlined,
                  iconColor: c.primary,
                  iconBackground: c.subtle(c.primary),
                  child: Column(
                    children: [
                      for (var i = 0; i < learn.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: i == learn.length - 1 ? 0 : 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(_learnIcons[i % _learnIcons.length],
                                  size: 18, color: c.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(learn[i],
                                    style: AppStyles.body12Primary(context)
                                        .copyWith(height: 1.4)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Rate this match (the buttons show what the user rated)
              _Card(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.thumbs_up_down_outlined,
                        size: 18, color: c.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(AiMatchStrings.helpfulQuestion,
                          style: AppStyles.body12SemiBold(context)),
                    ),
                    _ThumbButton(
                      icon: _rated == true
                          ? Icons.thumb_up_alt_rounded
                          : Icons.thumb_up_alt_outlined,
                      selected: _rated == true,
                      onTap: () => _rate(context, helpful: true),
                    ),
                    const SizedBox(width: 8),
                    _ThumbButton(
                      icon: _rated == false
                          ? Icons.thumb_down_alt_rounded
                          : Icons.thumb_down_alt_outlined,
                      selected: _rated == false,
                      onTap: () => _rate(context, helpful: false),
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: () => _rate(context),
                      child: Text(_rateLabel,
                          style:
                              AppStyles.body12Bold(context, color: c.primary)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Bottom actions
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: c.backgroundPrimary,
              border: Border(top: BorderSide(color: c.border)),
            ),
            child: SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _BottomButton(
                      label: AiMatchStrings.viewSkillGap,
                      leadingIcon: Icons.close_fullscreen_rounded,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.skillGap,
                        arguments: match,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BottomButton(
                      label: join.label,
                      leadingIcon: join.lead,
                      trailingIcon: join.trail,
                      filled: join.filled,
                      enabled: join.enabled,
                      loading: actions.sendingRequest,
                      onTap: () => context
                          .read<MatchActionsCubit>()
                          .requestToJoin(match),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// "3d ago", "5h ago"...
String _shortTimeAgo(DateTime? date) {
  if (date == null) return '';
  final d = DateTime.now().difference(date);
  if (d.inMinutes < 1) return 'now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  if (d.inDays < 30) return '${d.inDays}d ago';
  return '${(d.inDays / 30).floor()}mo ago';
}

/// White card, with an optional icon + title row on top.
class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.title,
    this.icon,
    this.iconColor,
    this.iconBackground,
    this.trailing,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final String? title;
  final IconData? icon;
  final Color? iconColor;

  /// When set, the icon sits inside a small rounded tile of this color.
  final Color? iconBackground;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: c.backgroundPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  if (iconBackground != null)
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: iconBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          Icon(icon, size: 17, color: iconColor ?? c.primary),
                    )
                  else
                    Icon(icon, size: 22, color: iconColor ?? c.primary),
                  const SizedBox(width: 10),
                ],
                Expanded(
                    child: Text(title!, style: AppStyles.title15Bold(context))),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}

/// Small pill label (AI MATCH INSIGHT, Verified Match, Mentored...).
class _Tag extends StatelessWidget {
  const _Tag({
    required this.label,
    required this.color,
    required this.background,
    this.icon,
  });

  final String label;
  final Color color;
  final Color background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.caption10Bold(context, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// 32x32 outlined icon button (bookmark, share). [active] = saved look.
class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: active ? c.subtle(c.primary) : c.backgroundPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? c.primary : c.border),
        ),
        child: Icon(icon,
            size: 16, color: active ? c.primary : c.textSecondary),
      ),
    );
  }
}

/// Solid blue skill chip with a check mark (matched skills).
class _VerifiedChip extends StatelessWidget {
  const _VerifiedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: c.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c.onPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.check_rounded, size: 14, color: c.onPrimary),
        ],
      ),
    );
  }
}

/// Soft tinted pill chip (complementary = blue, skills to develop = orange).
class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.iconColor,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: iconColor ?? foreground),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded box with an icon and a short text.
class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.text,
    required this.icon,
    this.iconColor,
    this.textColor,
    this.background,
  });

  final String text;
  final IconData icon;
  final Color? iconColor;
  final Color? textColor;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background ?? c.subtleBlueSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor ?? c.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: textColor ?? c.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small info line without a box (under the complementary skills).
class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.info_outline_rounded,
              size: 15, color: c.textSecondary),
        ),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: AppStyles.body12Secondary(context))),
      ],
    );
  }
}

/// Square thumbs up / down button. [selected] = what the user rated.
class _ThumbButton extends StatelessWidget {
  const _ThumbButton({
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: selected ? c.subtle(c.primary) : c.backgroundPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? c.subtle(c.primary) : c.border),
        ),
        child: Icon(icon,
            size: 17, color: selected ? c.primary : c.textSecondary),
      ),
    );
  }
}

/// Bottom bar button: outlined (View Skill Gap) or filled (Request to Join).
/// [enabled] = false greys it out (request already sent); [loading] shows a
/// small spinner.
class _BottomButton extends StatelessWidget {
  const _BottomButton({
    required this.label,
    required this.onTap,
    this.filled = false,
    this.enabled = true,
    this.loading = false,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool enabled;
  final bool loading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final Color fg;
    final Color bg;
    if (filled) {
      fg = c.onPrimary;
      bg = enabled ? c.primaryPressed : c.primaryPressed.withValues(alpha: 0.6);
    } else {
      fg = enabled ? c.primaryPressed : c.textSecondary;
      bg = c.backgroundPrimary;
    }
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: filled ? null : Border.all(color: c.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loading) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              ),
              const SizedBox(width: 8),
            ] else if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 17, color: fg),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ),
            if (!loading && trailingIcon != null) ...[
              const SizedBox(width: 6),
              Icon(trailingIcon, size: 17, color: fg),
            ],
          ],
        ),
      ),
    );
  }
}
