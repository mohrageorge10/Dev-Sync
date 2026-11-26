import 'dart:async';
import 'dart:typed_data';

import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/features/profile/data/model/detected_skill.dart';
import 'package:devsync/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter/material.dart';

// Inherited scope exposing ProfileController to profile screens.
class ProfileScope extends InheritedNotifier<ProfileController> {
  const ProfileScope({
    super.key,
    required ProfileController controller,
    required super.child,
  }) : super(notifier: controller);

  static ProfileController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ProfileScope>()!.notifier!;
}

// State controller for profile setup, editing, GitHub sync, and Firestore persistence.
class ProfileController extends ChangeNotifier {
  ProfileController({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  bool isLoading = false;
  bool isSaving = false;
  bool isUploadingAvatar = false;
  bool isUploadingResume = false;
  bool isCheckingUsername = false;
  bool? isUsernameAvailable;
  bool _hasLoaded = false;
  Timer? _usernameDebounce;

  // Basic info.
  String devSyncId = 'DS-89241';
  String displayName = '';
  String username = '';
  String bio = '';
  Uint8List? avatarBytes;
  String? photoUrl;

  // Technical profile.
  String? track;
  String? subTrack;
  final Set<String> secondaryTracks = {};
  String? level;
  final Map<String, String> languages = {};
  final List<String> customLanguages = [];
  final Set<String> frameworks = {};
  final List<String> customSkills = [];

  // Soft skills & interests.
  final Set<String> softSkills = {};
  final Set<String> domains = {};
  String background = '';

  // Documents & links.
  String? resumeName;
  String? resumeUrl;
  int resumeSize = 0;
  Uint8List? resumeBytes;
  String portfolio = '';
  String linkedin = '';
  String githubUrl = '';

  // GitHub state.
  bool githubConnected = false;
  GithubAnalysis? analysis;
  final Set<String> verifiedSkills = {};

  static const int maxSoftSkills = 4;
  static const List<String> levels = [
    'Beginner',
    'Junior',
    'Intermediate',
    'Advanced',
  ];

  void _update(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  // Load profile from Firestore once (or force refresh).
  Future<void> loadProfile({bool force = false}) async {
    if (_hasLoaded && !force) return;
    isLoading = true;
    notifyListeners();

    final uid = _repository.currentUserId;
    if (uid != null && uid.length >= 5) {
      devSyncId = 'DS-${uid.substring(0, 5).toUpperCase()}';
    }

    final doc = await _repository.fetchProfile();
    if (doc != null) {
      final publicId = doc[FirebaseConstants.fieldPublicId]?.toString();
      if (publicId != null && publicId.trim().isNotEmpty) {
        devSyncId = publicId.trim();
      }
      displayName =
          (doc[FirebaseConstants.fieldName] ??
                  _repository.currentDisplayName ??
                  '')
              .toString();
      username = (doc['username'] ?? _deriveUsername(displayName)).toString();
      if (username.trim().length >= 3) isUsernameAvailable = true;
      bio = (doc[FirebaseConstants.fieldBio] ?? '').toString();
      final rawPhoto = doc[FirebaseConstants.fieldPhotoUrl]?.toString();
      photoUrl = (rawPhoto != null && rawPhoto.trim().isNotEmpty)
          ? rawPhoto.trim()
          : null;

      final rawTrack = doc[FirebaseConstants.fieldTrack]?.toString();
      track = (rawTrack != null && rawTrack.trim().isNotEmpty)
          ? rawTrack.trim()
          : null;

      final rawSubTrack = doc['subTrack']?.toString();
      subTrack = (rawSubTrack != null && rawSubTrack.trim().isNotEmpty)
          ? rawSubTrack.trim()
          : null;

      secondaryTracks
        ..clear()
        ..addAll(_stringList(doc['secondaryTracks']));

      final rawLevel = doc[FirebaseConstants.fieldLevel]?.toString();
      level = (rawLevel != null && rawLevel.trim().isNotEmpty)
          ? rawLevel.trim()
          : null;

      languages.clear();
      final rawLangs = doc[FirebaseConstants.fieldLanguages];
      if (rawLangs is Map) {
        rawLangs.forEach((k, v) {
          languages[k.toString()] = v.toString();
        });
      } else if (rawLangs is Iterable) {
        for (final l in rawLangs) {
          languages[l.toString()] = 'Intermediate';
        }
      }

      frameworks.clear();
      final rawSkills = doc[FirebaseConstants.fieldSkills];
      if (rawSkills is Iterable) {
        for (final s in rawSkills) {
          final skill = s.toString();
          if (!languages.containsKey(skill)) {
            frameworks.add(skill);
          }
        }
      }

      softSkills
        ..clear()
        ..addAll(_stringList(doc[FirebaseConstants.fieldSoftSkills]));
      domains
        ..clear()
        ..addAll(_stringList(doc[FirebaseConstants.fieldInterests]));
      background = (doc[FirebaseConstants.fieldBackground] ?? '').toString();

      final cvName = doc[FirebaseConstants.fieldCvFileName]?.toString();
      resumeName = (cvName != null && cvName.trim().isNotEmpty) ? cvName : null;
      final cvUrl = doc[FirebaseConstants.fieldCvUrl]?.toString();
      resumeUrl = (cvUrl != null && cvUrl.trim().isNotEmpty) ? cvUrl : null;
      portfolio = (doc[FirebaseConstants.fieldPortfolioUrl] ?? '').toString();
      linkedin = (doc[FirebaseConstants.fieldLinkedinUrl] ?? '').toString();

      final ghUser = doc[FirebaseConstants.fieldGithubUsername]?.toString();
      if (ghUser != null && ghUser.trim().isNotEmpty) {
        githubUrl = 'https://github.com/${ghUser.trim()}';
      }
      githubConnected = doc[FirebaseConstants.fieldGithubConnected] == true;
    } else if (_repository.currentDisplayName != null && displayName.isEmpty) {
      displayName = _repository.currentDisplayName!;
      username = _deriveUsername(displayName);
    }

    _hasLoaded = true;
    isLoading = false;
    notifyListeners();
  }

  // Persist current profile state to Firestore users/{uid}.
  Future<void> saveProfile() async {
    isSaving = true;
    notifyListeners();

    final ghUsername = _extractGithubUsername();
    await _repository.saveProfile({
      FirebaseConstants.fieldPublicId: devSyncId,
      FirebaseConstants.fieldName: displayName.trim(),
      'username': username.trim(),
      'usernameLower': username.trim().toLowerCase(),
      FirebaseConstants.fieldBio: bio.trim(),
      FirebaseConstants.fieldPhotoUrl: photoUrl,
      if (track != null) FirebaseConstants.fieldTrack: track,
      'subTrack': subTrack,
      'secondaryTracks': secondaryTracks.toList(),
      if (level != null) FirebaseConstants.fieldLevel: level,
      FirebaseConstants.fieldLanguages: languages,
      FirebaseConstants.fieldSkills: allSkills,
      FirebaseConstants.fieldSoftSkills: softSkills.toList(),
      FirebaseConstants.fieldInterests: domains.toList(),
      FirebaseConstants.fieldBackground: background.trim(),
      FirebaseConstants.fieldCvFileName: resumeName,
      FirebaseConstants.fieldCvUrl: resumeUrl,
      FirebaseConstants.fieldPortfolioUrl: portfolio.trim(),
      FirebaseConstants.fieldLinkedinUrl: linkedin.trim(),
      FirebaseConstants.fieldGithubUsername: ghUsername,
      FirebaseConstants.fieldGithubConnected: githubConnected,
    });

    isSaving = false;
    notifyListeners();
  }

  // Sign out and clear local profile state.
  Future<void> signOut() async {
    await _repository.signOut();
    reset();
  }

  // Reset in-memory state when switching accounts.
  void reset() {
    _usernameDebounce?.cancel();
    isCheckingUsername = false;
    isUsernameAvailable = null;
    _hasLoaded = false;
    devSyncId = 'DS-89241';
    displayName = '';
    username = '';
    bio = '';
    avatarBytes = null;
    photoUrl = null;
    track = null;
    subTrack = null;
    secondaryTracks.clear();
    level = null;
    languages.clear();
    customLanguages.clear();
    frameworks.clear();
    customSkills.clear();
    softSkills.clear();
    domains.clear();
    background = '';
    resumeName = null;
    resumeUrl = null;
    resumeSize = 0;
    resumeBytes = null;
    portfolio = '';
    linkedin = '';
    githubUrl = '';
    githubConnected = false;
    analysis = null;
    verifiedSkills.clear();
    notifyListeners();
  }

  // Basic info mutators.
  bool get hasAvatar =>
      avatarBytes != null || (photoUrl != null && photoUrl!.isNotEmpty);

  Future<String?> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
  }) async {
    avatarBytes = bytes;
    isUploadingAvatar = true;
    notifyListeners();
    try {
      final url = await _repository.uploadAvatar(
        bytes: bytes,
        fileName: fileName,
      );
      photoUrl = url;
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isUploadingAvatar = false;
      notifyListeners();
    }
  }

  Future<void> clearAvatar() async {
    avatarBytes = null;
    photoUrl = null;
    notifyListeners();
    await _repository.saveProfile({FirebaseConstants.fieldPhotoUrl: null});
  }

  void setBasic({String? name, String? user, String? bioText}) {
    final userChanged = user != null && user != username;
    displayName = name ?? displayName;
    username = user ?? username;
    bio = bioText ?? bio;

    if (userChanged) {
      _usernameDebounce?.cancel();
      final trimmed = username.trim();
      if (trimmed.length < 3) {
        isCheckingUsername = false;
        isUsernameAvailable = null;
      } else {
        isCheckingUsername = true;
        isUsernameAvailable = null;
        _usernameDebounce = Timer(
          const Duration(milliseconds: 400),
          () => verifyUsernameNow(),
        );
      }
    }
    notifyListeners();
  }

  // Verify username uniqueness against Firestore immediately.
  Future<bool> verifyUsernameNow() async {
    final candidate = username.trim();
    if (candidate.length < 3) {
      isCheckingUsername = false;
      isUsernameAvailable = null;
      notifyListeners();
      return false;
    }
    isCheckingUsername = true;
    notifyListeners();
    final available = await _repository.isUsernameAvailable(candidate);
    if (username.trim() == candidate) {
      isCheckingUsername = false;
      isUsernameAvailable = available;
      notifyListeners();
    }
    return available;
  }

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    super.dispose();
  }

  bool get basicValid =>
      displayName.trim().isNotEmpty &&
      username.trim().length >= 3 &&
      !isCheckingUsername &&
      isUsernameAvailable != false;

  // Technical profile mutators.
  void setTrack(String value) => _update(() {
    if (track != value) subTrack = null;
    secondaryTracks.remove(value);
    track = value;
  });

  void toggleSecondaryTrack(String value) => _update(
    () => secondaryTracks.contains(value)
        ? secondaryTracks.remove(value)
        : secondaryTracks.add(value),
  );

  void setSubTrack(String? value) =>
      _update(() => subTrack = subTrack == value ? null : value);

  void setLevel(String value) => _update(() => level = value);

  void toggleLanguage(String lang) => _update(
    () => languages.containsKey(lang)
        ? languages.remove(lang)
        : languages[lang] = 'Intermediate',
  );

  void addCustomLanguage(String lang) => _update(() {
    final trimmed = lang.trim();
    if (trimmed.isEmpty) return;
    if (!customLanguages.contains(trimmed)) customLanguages.add(trimmed);
    languages.putIfAbsent(trimmed, () => 'Intermediate');
  });

  void setProficiency(String lang, String proficiency) =>
      _update(() => languages[lang] = proficiency);

  void toggleFramework(String framework) => _update(
    () => frameworks.contains(framework)
        ? frameworks.remove(framework)
        : frameworks.add(framework),
  );

  void addCustomSkill(String skill) => _update(() {
    final trimmed = skill.trim();
    if (trimmed.isEmpty) return;
    if (!customSkills.contains(trimmed)) customSkills.add(trimmed);
    frameworks.add(trimmed);
  });

  bool get technicalValid =>
      track != null && level != null && languages.isNotEmpty;

  // Soft skills & interests mutators.
  bool toggleSoft(String skill) {
    if (softSkills.contains(skill)) {
      _update(() => softSkills.remove(skill));
      return true;
    }
    if (softSkills.length >= maxSoftSkills) return false;
    _update(() => softSkills.add(skill));
    return true;
  }

  void toggleDomain(String domain) => _update(
    () => domains.contains(domain)
        ? domains.remove(domain)
        : domains.add(domain),
  );

  void setBackground(String value) => _update(() => background = value);
  bool get softValid => softSkills.isNotEmpty;

  // Documents & links mutators.
  Future<String?> uploadResume({
    required String name,
    required int size,
    required Uint8List bytes,
  }) async {
    isUploadingResume = true;
    notifyListeners();
    try {
      final url = await _repository.uploadCv(bytes: bytes, fileName: name);
      resumeName = name;
      resumeSize = size;
      resumeBytes = bytes;
      resumeUrl = url;
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isUploadingResume = false;
      notifyListeners();
    }
  }

  Future<void> clearResume() async {
    resumeName = null;
    resumeUrl = null;
    resumeSize = 0;
    resumeBytes = null;
    notifyListeners();
    await _repository.saveProfile({
      FirebaseConstants.fieldCvFileName: null,
      FirebaseConstants.fieldCvUrl: null,
    });
  }

  void setLinks({
    String? portfolioUrl,
    String? linkedinUrl,
    String? github,
  }) => _update(() {
    portfolio = portfolioUrl ?? portfolio;
    linkedin = linkedinUrl ?? linkedin;
    githubUrl = github ?? githubUrl;
  });

  // GitHub flow mutators.
  void setAnalysis(GithubAnalysis result) => _update(() {
    analysis = result;
    if (githubUrl.isEmpty) {
      githubUrl = 'https://github.com/${result.username}';
    }
  });

  void markGithubConnected() => _update(() => githubConnected = true);

  void addDetected(DetectedSkill skill) => _update(() {
    skill.status = SkillStatus.added;
    verifiedSkills.add(skill.name);
  });

  void undoDetected(DetectedSkill skill) => _update(() {
    skill.status = SkillStatus.suggested;
    verifiedSkills.remove(skill.name);
  });

  void dismissDetected(DetectedSkill skill) =>
      _update(() => skill.status = SkillStatus.dismissed);

  void addAllDetected() {
    for (final s in analysis?.skills ?? <DetectedSkill>[]) {
      if (s.status == SkillStatus.suggested) addDetected(s);
    }
  }

  // Only suggest detected skills that are not already in the user's profile.
  List<DetectedSkill> get pendingSuggestions {
    final existing = {
      ...languages.keys,
      ...frameworks,
      ...verifiedSkills,
    }.map((e) => e.trim().toLowerCase()).toSet();

    return (analysis?.skills ?? [])
        .where(
          (s) =>
              s.status == SkillStatus.suggested &&
              !existing.contains(s.name.trim().toLowerCase()),
        )
        .toList();
  }

  int get addedCount =>
      (analysis?.skills ?? [])
          .where((s) => s.status == SkillStatus.added)
          .length;

  // Removes GitHub analysis data while keeping already verified skills.
  void disconnectGithub() => _update(() {
    githubConnected = false;
    analysis = null;
    githubUrl = '';
  });

  // Validation messages for step footers (null means valid).
  String? get basicBlockedReason => displayName.trim().isEmpty
      ? 'Enter your display name to continue'
      : username.trim().length < 3
      ? 'Username must be at least 3 characters'
      : isCheckingUsername
      ? 'Checking username availability...'
      : isUsernameAvailable == false
      ? 'This username is already taken'
      : null;

  String? get technicalBlockedReason => track == null
      ? 'Pick your main engineering track'
      : level == null
      ? 'Choose your experience level'
      : languages.isEmpty
      ? 'Select at least one programming language'
      : null;

  String? get softBlockedReason =>
      softSkills.isEmpty ? 'Pick at least one soft skill' : null;

  String? get resumeBlockedReason => resumeName == null
      ? 'Upload your CV (PDF) to continue'
      : linkedin.trim().isEmpty
      ? 'Enter your LinkedIn profile URL to continue'
      : null;

  String? get connectWorkBlockedReason =>
      !githubConnected ? 'Connect your GitHub account to continue' : null;

  // Profile completion checklist.
  List<ChecklistItem> get checklist => [
    ChecklistItem(
      'Basic Info',
      'Bio, title, location & timezone',
      basicValid,
    ),
    ChecklistItem(
      'Track & Experience Level',
      track != null && level != null
          ? '$track • $level'
          : 'Your discipline and seniority',
      track != null && level != null,
    ),
    ChecklistItem(
      'Languages & Frameworks',
      languages.isNotEmpty
          ? [...languages.keys, ...frameworks].take(4).join(', ')
          : 'Your core toolset',
      languages.isNotEmpty,
    ),
    ChecklistItem(
      'Soft Skills & Interests',
      softSkills.isNotEmpty
          ? softSkills.take(2).join(', ')
          : 'How you collaborate',
      softSkills.isNotEmpty,
    ),
    ChecklistItem(
      'CV',
      resumeName ?? 'Upload your PDF CV',
      resumeName != null,
    ),
    ChecklistItem(
      'Portfolio Link',
      portfolio.trim().isNotEmpty ? portfolio : 'Showcase your best work',
      portfolio.trim().isNotEmpty,
    ),
    ChecklistItem(
      'LinkedIn Link',
      linkedin.trim().isNotEmpty
          ? linkedin
          : 'Expands your professional network',
      linkedin.trim().isNotEmpty,
    ),
    ChecklistItem(
      'GitHub Connection',
      githubConnected
          ? '@${analysis?.username ?? _extractGithubUsername() ?? 'connected'}'
          : 'Adds evidence for your skills from code',
      githubConnected,
    ),
  ];

  int get completedItems => checklist.where((e) => e.done).length;
  int get completion => (completedItems * 100 / checklist.length).round();

  List<String> get allSkills => {
    if (subTrack != null && subTrack!.isNotEmpty) subTrack!,
    ...languages.keys,
    ...frameworks,
    ...verifiedSkills,
  }.toList();

  String? _extractGithubUsername() {
    if (analysis?.username.isNotEmpty == true) return analysis!.username;
    final clean = githubUrl.trim().replaceFirst(
      RegExp(r'^https?://(www\.)?github\.com/'),
      '',
    );
    return clean.isEmpty ? null : clean.split('/').first;
  }

  static String _deriveUsername(String name) {
    final cleaned = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return cleaned.length >= 3 ? cleaned : '';
  }

  static List<String> _stringList(dynamic value) {
    if (value is! Iterable) return const [];
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
}

// Single item in the profile completion checklist.
class ChecklistItem {
  const ChecklistItem(this.title, this.subtitle, this.done);

  final String title;
  final String subtitle;
  final bool done;
}

// Formats a byte count into KB or MB.
String formatBytes(int bytes) {
  if (bytes <= 0) return '0 KB';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
