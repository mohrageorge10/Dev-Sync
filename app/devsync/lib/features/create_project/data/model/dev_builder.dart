import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/enums.dart';
import 'package:devsync/features/create_project/data/model/team_track.dart';
import 'package:equatable/equatable.dart';

// Registered developer model.
class DevBuilder extends Equatable {
  const DevBuilder({
    required this.id,
    required this.name,
    required this.publicId,
    required this.track,
    required this.skills,
    this.level = UserLevel.intermediate,
    this.photoUrl = '',
    this.availableNow = true,
  });

  // Parse from Firestore user document.
  factory DevBuilder.fromFirestore(Map<String, dynamic> map) {
    final id = (map['id'] ?? map[FirebaseConstants.fieldUid] ?? '').toString();
    final rawSkills = map[FirebaseConstants.fieldSkills];
    return DevBuilder(
      id: id,
      name: (map[FirebaseConstants.fieldName] ?? 'Developer').toString(),
      publicId: (map[FirebaseConstants.fieldPublicId] ??
              map[FirebaseConstants.fieldGithubUsername] ??
              id)
          .toString(),
      photoUrl: (map[FirebaseConstants.fieldPhotoUrl] ?? '').toString(),
      track: UserTrackX.fromName(map[FirebaseConstants.fieldTrack]?.toString()),
      level: UserLevelParserX.fromName(
        map[FirebaseConstants.fieldLevel]?.toString(),
      ),
      skills: [
        if (rawSkills is Iterable)
          for (final item in rawSkills)
            if (item is String)
              item
            else if (item is Map && item[FirebaseConstants.fieldSkill] != null)
              item[FirebaseConstants.fieldSkill].toString(),
      ],
    );
  }

  final String id, name, publicId, photoUrl;
  final UserTrack track;
  final UserLevel level;
  final List<String> skills;
  final bool availableNow;

  String get handle => publicId;
  String get trackId => track.name;
  String get displayHandle => publicId.startsWith('@') ? publicId : '@$publicId';

  // Invitee snapshot for Firestore.
  Map<String, dynamic> toSnapshot() => {
        FirebaseConstants.fieldUid: id,
        FirebaseConstants.fieldName: name,
        FirebaseConstants.fieldPhotoUrl: photoUrl,
        FirebaseConstants.fieldPublicId: publicId,
        FirebaseConstants.fieldTrack: track.name,
        FirebaseConstants.fieldLevel: level.name,
      };

  // Avatar initials fallback.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  // Track compatibility score (0..100).
  int matchPercent(TeamTrack t) {
    final wanted = {...t.skills, ...t.definition.skills.take(3)}
        .map((s) => s.toLowerCase())
        .toSet();
    final have = skills.map((s) => s.toLowerCase()).toSet();
    final overlap =
        wanted.isEmpty ? 0.0 : wanted.intersection(have).length / wanted.length;
    final score =
        (track == t.definition.track ? 0.5 : 0.0) + (0.4 * overlap) + (availableNow ? 0.1 : 0.0);
    return (score * 100).round().clamp(0, 100);
  }

  @override
  List<Object?> get props =>
      [id, name, publicId, photoUrl, track, level, skills, availableNow];
}
