import 'package:devsync/core/services/firebase/firebase_constants.dart';
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
    this.projects = const [],
  });

  // Parse from Firestore user document.
  factory DeveloperModel.fromFirestore(Map<String, dynamic> map) {
    final id = (map[FirebaseConstants.fieldUid] ?? map['id'] ?? '').toString();
    final track = UserTrackX.fromName(
      map[FirebaseConstants.fieldTrack]?.toString(),
    );
    final rawLevel =
        (map[FirebaseConstants.fieldLevel] ?? 'intermediate').toString();
    final level = UserLevel.values.firstWhere(
      (l) => l.name == rawLevel.toLowerCase(),
      orElse: () => UserLevel.intermediate,
    );

    final rawSkills = map[FirebaseConstants.fieldSkills];
    final skills = <String>[
      if (rawSkills is Iterable)
        for (final s in rawSkills) s.toString(),
    ];

    final photo = map[FirebaseConstants.fieldPhotoUrl]?.toString();
    final bio = (map[FirebaseConstants.fieldBio] ?? '').toString();
    final handle = map[FirebaseConstants.fieldPublicId]?.toString();
    final hasGithub = map[FirebaseConstants.fieldGithubConnected] == true;
    final ghUser = map[FirebaseConstants.fieldGithubUsername]?.toString();
    final cleanHandle = (ghUser != null && ghUser.trim().isNotEmpty)
        ? ghUser.trim().replaceAll('@', '')
        : (handle != null && handle.isNotEmpty)
        ? handle.replaceAll('@', '')
        : id;

    final rawCv = map[FirebaseConstants.fieldCvUrl]?.toString().trim();
    final rawCvName = map[FirebaseConstants.fieldCvFileName]?.toString().trim();
    final rawPortfolio = map[FirebaseConstants.fieldPortfolioUrl]
        ?.toString()
        .trim();
    final rawLinkedin = map[FirebaseConstants.fieldLinkedinUrl]
        ?.toString()
        .trim();

    final matchPercent = (78 + (skills.length * 4)).clamp(75, 98);

    return DeveloperModel(
      id: id,
      name: (map[FirebaseConstants.fieldName] ?? 'Developer').toString(),
      publicId: handle,
      imageUrl: (photo != null && photo.isNotEmpty) ? photo : null,
      hasGithub: hasGithub,
      role: track.label,
      level: level.label,
      skills: skills.isEmpty ? const ['Flutter', 'Dart'] : skills,
      bio: bio.isNotEmpty
          ? bio
          : '${track.label} engineer ready to collaborate on open builds.',
      matchPercent: matchPercent,
      repositoriesCount: '${8 + skills.length * 2}',
      commitsCount: '${180 + skills.length * 45}',
      projectsCount: '${2 + (skills.length ~/ 2)}',
      githubUrl: hasGithub ? 'https://github.com/$cleanHandle' : null,
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
    );
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
  final List<PortfolioProjectData> projects;

  bool get hasCv => cvUrl != null && cvUrl!.trim().isNotEmpty;

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

  // Dynamic social links based on developer profile.
  List<SocialLinkItem> get socialLinks {
    final user = username;
    return [
      SocialLinkItem(
        icon: Icons.code_rounded,
        title: 'GitHub',
        subtitle: '@$user',
        url: githubUrl ?? 'https://github.com/$user',
        isConnected: hasGithub,
      ),
      if (portfolioUrl != null && portfolioUrl!.isNotEmpty)
        SocialLinkItem(
          icon: Icons.language_rounded,
          title: 'Portfolio / CV',
          subtitle: portfolioUrl!,
          url: portfolioUrl!,
          isConnected: true,
          trailingIcon: Icons.north_east_rounded,
        )
      else
        SocialLinkItem(
          icon: Icons.language_rounded,
          title: 'Portfolio Website',
          subtitle: 'https://$user.dev',
          url: 'https://$user.dev',
          trailingIcon: Icons.north_east_rounded,
        ),
      SocialLinkItem(
        icon: Icons.work_outline_rounded,
        title: 'LinkedIn',
        subtitle: 'in/$user',
        url: linkedinUrl ?? 'https://www.linkedin.com/in/$user',
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
