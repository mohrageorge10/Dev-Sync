import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:equatable/equatable.dart';

/// How strong the match is (derived from the score).
enum MatchFit { strong, good, partial }

/// One "how to prepare" tip for a missing skill.
/// [whyItMatters], [whatToLearn] and [firstStep] are optional design details.
class LearningTip extends Equatable {
  const LearningTip({
    required this.skill,
    required this.tip,
    this.whyItMatters = '',
    this.whatToLearn = '',
    this.firstStep = '',
  });

  final String skill;
  final String tip;
  final String whyItMatters, whatToLearn, firstStep;

  // Accepts a plain String (tip only) or a map { skill, tip, ... }.
  static LearningTip? fromDynamic(dynamic raw) {
    if (raw is String && raw.trim().isNotEmpty) {
      return LearningTip(skill: '', tip: raw);
    }
    if (raw is Map) {
      final tip = (raw[FirebaseConstants.fieldTip] ?? '').toString();
      final skill = (raw[FirebaseConstants.fieldSkill] ?? '').toString();
      final why = (raw['whyItMatters'] ?? '').toString();
      final what = (raw['whatToLearn'] ?? '').toString();
      final first = (raw['firstStep'] ?? '').toString();
      if (tip.isEmpty && skill.isEmpty && why.isEmpty && first.isEmpty) {
        return null;
      }
      return LearningTip(
        skill: skill,
        tip: tip,
        whyItMatters: why,
        whatToLearn: what,
        firstStep: first,
      );
    }
    return null;
  }

  @override
  List<Object?> get props =>
      [skill, tip, whyItMatters, whatToLearn, firstStep];
}

/// Extra info about a skill the user already has ("Verified from 14 commits").
class SkillDetail extends Equatable {
  const SkillDetail({required this.skill, this.note = '', this.level = ''});

  final String skill, note, level;

  static SkillDetail? fromDynamic(dynamic raw) {
    if (raw is! Map) return null;
    final skill = (raw['skill'] ?? '').toString();
    if (skill.isEmpty) return null;
    return SkillDetail(
      skill: skill,
      note: (raw['note'] ?? '').toString(),
      level: (raw['level'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [skill, note, level];
}

/// One line of "Mentorship & Growth Highlights".
class MatchHighlight extends Equatable {
  const MatchHighlight({
    required this.title,
    this.subtitle = '',
    this.avatarUrl = '',
  });

  final String title, subtitle;

  /// Optional photo (e.g. the maintainer). Empty = an icon is shown.
  final String avatarUrl;

  static MatchHighlight? fromDynamic(dynamic raw) {
    if (raw is! Map) return null;
    final title = (raw['title'] ?? '').toString();
    if (title.isEmpty) return null;
    return MatchHighlight(
      title: title,
      subtitle: (raw['subtitle'] ?? '').toString(),
      avatarUrl: (raw['avatarUrl'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [title, subtitle, avatarUrl];
}

/// AI match between the current user and one project.
/// Stored in `matches/{uid}/items/{projectId}`.
class MatchModel extends Equatable {
  const MatchModel({
    required this.projectId,
    required this.projectTitle,
    required this.score,
    this.projectDescription = '',
    this.purpose = ProjectPurpose.learning,
    this.matchedSkills = const [],
    this.missingSkills = const [],
    this.complementarySkills = const [],
    this.learningTips = const [],
    this.matchedTrack = '',
    this.explanation = '',
    this.source = MatchSource.llm,
    this.createdAt,
    this.leadMaintainer = '',
    this.sprintLabel = '',
    this.learnPoints = const [],
    this.skillDetails = const [],
    this.highlights = const [],
  });

  factory MatchModel.fromFirestore(Map<String, dynamic> map) {
    List<String> strings(dynamic v) => v is Iterable
        ? [for (final i in v) if (i != null) i.toString()]
        : const [];

    T byName<T extends Enum>(List<T> values, dynamic name, T fallback) {
      for (final v in values) {
        if (v.name == name) return v;
      }
      return fallback;
    }

    final rawTips = map[FirebaseConstants.fieldLearningTips];
    final createdAt = map[FirebaseConstants.fieldCreatedAt];
    final tips = <LearningTip>[];
    if (rawTips is Iterable) {
      for (final t in rawTips) {
        final parsed = LearningTip.fromDynamic(t);
        if (parsed != null) tips.add(parsed);
      }
    }

    return MatchModel(
      projectId:
          (map[FirebaseConstants.fieldProjectId] ?? map['id'] ?? '').toString(),
      projectTitle:
          (map[FirebaseConstants.fieldProjectTitle] ?? 'Project').toString(),
      projectDescription:
          (map[FirebaseConstants.fieldDescription] ?? '').toString(),
      purpose: byName(ProjectPurpose.values,
          map[FirebaseConstants.fieldPurpose], ProjectPurpose.learning),
      score: ((map[FirebaseConstants.fieldScore] ?? 0) as num)
          .round()
          .clamp(0, 100),
      matchedSkills: strings(map[FirebaseConstants.fieldMatchedSkills]),
      missingSkills: strings(map[FirebaseConstants.fieldMissingSkills]),
      complementarySkills:
          strings(map[FirebaseConstants.fieldComplementarySkills]),
      learningTips: tips,
      matchedTrack: (map[FirebaseConstants.fieldMatchedTrack] ?? '').toString(),
      explanation: (map[FirebaseConstants.fieldExplanation] ?? '').toString(),
      source: byName(MatchSource.values,
          map[FirebaseConstants.fieldMatchSource], MatchSource.llm),
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      leadMaintainer: (map['leadMaintainer'] ?? '').toString(),
      sprintLabel: (map['sprintLabel'] ?? '').toString(),
      learnPoints: strings(map['learnPoints']),
      skillDetails: [
        if (map['skillDetails'] is Iterable)
          for (final d in map['skillDetails'] as Iterable)
            if (SkillDetail.fromDynamic(d) != null) SkillDetail.fromDynamic(d)!,
      ],
      highlights: [
        if (map['highlights'] is Iterable)
          for (final h in map['highlights'] as Iterable)
            if (MatchHighlight.fromDynamic(h) != null)
              MatchHighlight.fromDynamic(h)!,
      ],
    );
  }

  final String projectId, projectTitle, projectDescription;
  final ProjectPurpose purpose;
  final int score;
  final List<String> matchedSkills, missingSkills, complementarySkills;
  final List<LearningTip> learningTips;
  final String matchedTrack, explanation;
  final MatchSource source;
  final DateTime? createdAt;
  // Optional design details (shown on the "Why this fits" screen).
  final String leadMaintainer, sprintLabel;
  final List<String> learnPoints;
  // Optional design details (shown on the "Skill gap" screen).
  final List<SkillDetail> skillDetails;
  final List<MatchHighlight> highlights;

  // Details of one matched skill (null when there is none).
  SkillDetail? detailFor(String skill) {
    for (final d in skillDetails) {
      if (d.skill.toLowerCase() == skill.toLowerCase()) return d;
    }
    return null;
  }

  MatchFit get fit => score >= 80
      ? MatchFit.strong
      : score >= 60
          ? MatchFit.good
          : MatchFit.partial;

  String get fitLabel => switch (fit) {
        MatchFit.strong => 'Strong Fit',
        MatchFit.good => 'Good Fit',
        MatchFit.partial => 'Partial Fit',
      };

  // Total skills the project asks for.
  int get requiredCount => matchedSkills.length + missingSkills.length;

  // Where the analysis came from.
  String get sourceLabel => switch (source) {
        MatchSource.llm => 'AI Generated',
        MatchSource.cached => 'Saved Analysis',
        MatchSource.fallback => 'Estimated',
      };

  @override
  List<Object?> get props => [
        projectId,
        projectTitle,
        projectDescription,
        purpose,
        score,
        matchedSkills,
        missingSkills,
        complementarySkills,
        learningTips,
        matchedTrack,
        explanation,
        source,
        createdAt,
        leadMaintainer,
        sprintLabel,
        learnPoints,
        skillDetails,
        highlights,
      ];
}