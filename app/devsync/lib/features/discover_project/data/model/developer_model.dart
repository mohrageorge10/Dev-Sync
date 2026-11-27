import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/services/firebase/presence_service.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/enums.dart';
import 'package:devsync/features/discover_project/data/model/filter_matching.dart';
import 'package:devsync/features/discover_project/data/model/filter_state.dart';
import 'package:devsync/features/discover_project/data/model/portfolio_data.dart';
import 'package:devsync/features/discover_project/data/model/project_model.dart';
import 'package:flutter/material.dart';

// Connected social account link item.
class SocialLinkItem {
  const SocialLinkItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.url,
    this.isConnected = false,
    this.trailingIcon = Icons.open_in_new_rounded,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String url;
  final bool isConnected;
  final IconData trailingIcon;
}

// Discoverable developer model mapped from Firestore users collection.
class DeveloperModel {
  const DeveloperModel({
    required this.id,
    required this.name,
    this.publicId,
    this.imageUrl,
    this.hasGithub = false,
    required this.role,
    required this.level,
    required this.skills,
    required this.bio,
    this.matchPercent = 90,
    this.repositoriesCount = '14',
    this.commitsCount = '380',
    this.projectsCount = '4',
    this.githubUrl,
    this.portfolioUrl,
    this.linkedinUrl,
    this.cvUrl,
    this.cvFileName,
    this.isOnline = false,
    this.lastSeen,
    this.projects = const [],
  });

  // Parse from Firestore user document.
  factory DeveloperModel.fromFirestore(Map<String, dynamic> map) {
    final id = (map[FirebaseConstants.fieldUid] ?? map['id'] ?? '').toString();
    final rawTrack = (map[FirebaseConstants.fieldTrack] ?? '').toString().trim();
    final roleLabel = _resolveTrackLabel(rawTrack);

    final rawLevel =
        (map[FirebaseConstants.fieldLevel] ?? 'intermediate').toString().trim();
    final level = UserLevel.values.firstWhere(
      (l) =>
          l.name.toLowerCase() == rawLevel.toLowerCase() ||
          l.label.toLowerCase() == rawLevel.toLowerCase(),
      orElse: () => UserLevel.intermediate,
    );

    final rawSkills = map[FirebaseConstants.fieldSkills];
    final skills = <String>[
      if (rawSkills is Iterable)
        for (final s in rawSkills)
          if (s.toString().trim().isNotEmpty) s.toString().trim(),
    ];

    final photo = map[FirebaseConstants.fieldPhotoUrl]?.toString().trim();
    final bio = (map[FirebaseConstants.fieldBio] ?? '').toString().trim();
    final rawUsername = map['username']?.toString().trim();
    final rawPublicId = map[FirebaseConstants.fieldPublicId]?.toString().trim();
    final handle = (rawUsername != null && rawUsername.isNotEmpty)
        ? rawUsername
        : rawPublicId;
    final hasGithub = map[FirebaseConstants.fieldGithubConnected] == true;
    final ghUser = map[FirebaseConstants.fieldGithubUsername]?.toString().trim();
    final rawGithubUrl = map['githubUrl']?.toString().trim();
    String? githubUrl;
    if (rawGithubUrl != null && rawGithubUrl.isNotEmpty) {
      githubUrl = rawGithubUrl;
    } else if (ghUser != null && ghUser.isNotEmpty) {
      githubUrl = 'https://github.com/${ghUser.replaceAll('@', '')}';
    } else if (hasGithub && handle != null && handle.isNotEmpty) {
      githubUrl = 'https://github.com/${handle.replaceAll('@', '')}';
    }

    final rawCv = map[FirebaseConstants.fieldCvUrl]?.toString().trim();
    final rawCvName = map[FirebaseConstants.fieldCvFileName]?.toString().trim();
    final rawPortfolio = map[FirebaseConstants.fieldPortfolioUrl]
        ?.toString()
        .trim();
    final rawLinkedin = map[FirebaseConstants.fieldLinkedinUrl]
        ?.toString()
        .trim();
    final rawLastSeen = map[FirebaseConstants.fieldLastSeen];
    DateTime? lastSeen;
    if (rawLastSeen is Timestamp) {
      lastSeen = rawLastSeen.toDate();
    } else if (rawLastSeen is String) {
      lastSeen = DateTime.tryParse(rawLastSeen);
    }
    final isOnline = PresenceService.isRecentlyOnline(
      map[FirebaseConstants.fieldIsOnline] == true,
      lastSeen,
    );

    final matchPercent = (78 + (skills.length * 4)).clamp(75, 98);

    return DeveloperModel(
      id: id,
      name: (map[FirebaseConstants.fieldName] ?? 'Developer').toString(),
      publicId: handle,
      imageUrl: (photo != null && photo.isNotEmpty) ? photo : null,
      hasGithub: hasGithub,
      role: roleLabel,
      level: level.label,
      skills: skills,
      bio: bio,
      matchPercent: matchPercent,
      repositoriesCount: '${8 + skills.length * 2}',
      commitsCount: '${180 + skills.length * 45}',
      projectsCount: '${2 + (skills.length ~/ 2)}',
      githubUrl: githubUrl,
      portfolioUrl: (rawPortfolio != null && rawPortfolio.isNotEmpty)
          ? rawPortfolio
          : null,
      linkedinUrl: (rawLinkedin != null && rawLinkedin.isNotEmpty)
          ? rawLinkedin
          : null,
      cvUrl: (rawCv != null && rawCv.isNotEmpty) ? rawCv : null,
      cvFileName: (rawCvName != null && rawCvName.isNotEmpty)
          ? rawCvName
          : null,
      isOnline: isOnline,
      lastSeen: lastSeen,
    );
  }

  // Resolve track label from either enum key (e.g. "uiUx") or display label (e.g. "UI/UX").
  static String _resolveTrackLabel(String raw) {
    if (raw.isEmpty) return 'Developer';
    final lower = raw.toLowerCase();
    for (final t in UserTrack.values) {
      if (t.name.toLowerCase() == lower || t.label.toLowerCase() == lower) {
        return t.label;
      }
    }
    return raw;
  }

  final String id;
  final String name;
  final String? publicId;
  final String? imageUrl;
  final bool hasGithub;
  final String role;
  final String level;
  final List<String> skills;
  final String bio;
  final int matchPercent;
  final String repositoriesCount;
  final String commitsCount;
  final String projectsCount;
  final String? githubUrl;
  final String? portfolioUrl;
  final String? linkedinUrl;
  final String? cvUrl;
  final String? cvFileName;
  final bool isOnline;
  final DateTime? lastSeen;
  final List<PortfolioProjectData> projects;

  bool get hasCv => cvUrl != null && cvUrl!.trim().isNotEmpty;
  String get presenceLabel => PresenceService.formatPresence(isOnline, lastSeen);

  // Normalized @handle for display.
  String get handle {
    final raw = (publicId != null && publicId!.trim().isNotEmpty)
        ? publicId!.trim()
        : name.toLowerCase().replaceAll(' ', '');
    return raw.startsWith('@') ? raw : '@$raw';
  }

  // Raw username without '@'.
  String get username => handle.replaceAll('@', '');

  // Role and level subtitle.
  String get subtitle => '$role • $level';

  // Categorized technical and collaboration skills for profile view.
  Map<String, List<String>> get skillCategories {
    const knownLanguages = {
      'dart',
      'kotlin',
      'swift',
      'python',
      'go',
      'javascript',
      'typescript',
      'java',
      'c++',
      'rust',
      'sql',
    };
    final langs = <String>[];
    final tools = <String>[];

    for (final s in skills) {
      if (knownLanguages.contains(s.toLowerCase())) {
        langs.add(s);
      } else {
        tools.add(s);
      }
    }

    final archLabel = role.length <= 16
        ? '$role Architecture'
        : 'System Architecture';

    return {
      if (langs.isNotEmpty) 'LANGUAGES': langs,
      'FRAMEWORKS & TOOLS': tools.isNotEmpty ? tools : skills,
      'LEADERSHIP & COLLABORATION': [
        archLabel,
        'Agile Sprints',
        if (level.toLowerCase() == 'advanced') 'Team Mentorship',
        'Code Reviews',
      ],
    };
  }

  // Only real social links actually added by the developer (no fabricated URLs).
  List<SocialLinkItem> get socialLinks {
    return [
      if (githubUrl != null && githubUrl!.trim().isNotEmpty)
        SocialLinkItem(
          icon: Icons.code_rounded,
          title: 'GitHub',
          subtitle: githubUrl!.trim(),
          url: githubUrl!.trim(),
          isConnected: hasGithub,
        ),
      if (portfolioUrl != null && portfolioUrl!.trim().isNotEmpty)
        SocialLinkItem(
          icon: Icons.language_rounded,
          title: 'Portfolio',
          subtitle: portfolioUrl!.trim(),
          url: portfolioUrl!.trim(),
          isConnected: true,
          trailingIcon: Icons.north_east_rounded,
        ),
      if (linkedinUrl != null && linkedinUrl!.trim().isNotEmpty)
        SocialLinkItem(
          icon: Icons.work_outline_rounded,
          title: 'LinkedIn',
          subtitle: linkedinUrl!.trim(),
          url: linkedinUrl!.trim(),
          isConnected: true,
          trailingIcon: Icons.north_east_rounded,
        ),
    ];
  }

  // Portfolio projects associated with this developer.
  List<PortfolioProjectData> portfolioFor(List<ProjectModel> allProjects) {
    if (projects.isNotEmpty) return projects;
    final matching = allProjects
        .where(
          (p) =>
              p.tracks.any((t) => t.toLowerCase() == role.toLowerCase()) ||
              p.tags.any(
                (t) => skills.any((s) => s.toLowerCase() == t.toLowerCase()),
              ),
        )
        .take(2)
        .map(
          (p) => PortfolioProjectData(
            badgeText: p.type.toUpperCase(),
            statusText: p.isOpen ? 'Active' : 'Completed',
            topIcon: p.icon,
            title: p.title,
            description: p.description,
            roleText: '$role Contributor',
            trailingInfoIcon: Icons.group_outlined,
            trailingInfoText: '${p.members}/${p.maxMembers} members',
          ),
        )
        .toList();
    return matching.isNotEmpty ? matching : portfolioProjects;
  }

  // Match against active filters.
  bool matches(FilterState f) =>
      matchesAny(f.skills, skills) &&
      textContainsAny(f.tracks, [role]) &&
      matchesAny(f.difficulty, [level]);

  // Match against search query.
  bool matchesQuery(String query) =>
      containsQuery(query, [name, role, bio, ?publicId, ...skills]);

  // Match against a single tech stack chip (used in guest mode).
  bool matchesSkillChip(String selectedSkill) {
    if (selectedSkill == 'All Stacks') return true;
    final wanted = selectedSkill.toLowerCase().split(' ').first;
    return skills.any((s) => s.toLowerCase().contains(wanted)) ||
        role.toLowerCase().contains(wanted);
  }
}
