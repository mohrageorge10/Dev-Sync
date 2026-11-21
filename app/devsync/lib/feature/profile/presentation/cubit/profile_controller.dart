import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data/models/detected_skill.dart';

class ProfileScope extends InheritedNotifier<ProfileController> {
  const ProfileScope({super.key, required ProfileController controller, required super.child}) : super(notifier: controller);
  static ProfileController of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<ProfileScope>()!.notifier!;
}

class ProfileController extends ChangeNotifier {
  // ── Basic info
  final String devSyncId = 'DS-89241';
  String displayName = '';
  String username = '';
  String bio = '';
  Uint8List? avatarBytes;

  // ── Technical profile
  String? track;
  String? level;
  final Map<String, String> languages = {}; // name -> proficiency
  final Set<String> frameworks = {};
  final List<String> customSkills = [];

  // ── Soft skills & interests
  final Set<String> softSkills = {};
  final Set<String> domains = {};
  String background = '';

  // ── Documents & links
  String? resumeName;
  int resumeSize = 0;
  Uint8List? resumeBytes;
  String portfolio = '';
  String linkedin = '';
  String githubUrl = '';

  // ── GitHub
  bool githubConnected = false;
  GithubAnalysis? analysis;
  final Set<String> verifiedSkills = {}; // survive disconnect

  static const maxSoftSkills = 4;
  static const levels = ['Beginner', 'Junior', 'Intermediate', 'Advanced'];

  void _n(VoidCallback f) {
    f();
    notifyListeners();
  }

  // Basic
  void setAvatar(Uint8List? b) => _n(() => avatarBytes = b);
  void setBasic({String? name, String? user, String? bioText}) => _n(() {
        displayName = name ?? displayName;
        username = user ?? username;
        bio = bioText ?? bio;
      });
  bool get basicValid => displayName.trim().isNotEmpty && username.trim().length >= 3;

  // Technical
  void setTrack(String t) => _n(() => track = t);
  void setLevel(String l) => _n(() => level = l);
  void toggleLanguage(String l) => _n(() => languages.containsKey(l) ? languages.remove(l) : languages[l] = 'Intermediate');
  void setProficiency(String l, String p) => _n(() => languages[l] = p);
  void toggleFramework(String f) => _n(() => frameworks.contains(f) ? frameworks.remove(f) : frameworks.add(f));
  void addCustomSkill(String s) => _n(() {
        final v = s.trim();
        if (v.isEmpty) return;
        customSkills.add(v);
        frameworks.add(v);
      });
  bool get technicalValid => track != null && level != null && languages.isNotEmpty;

  // Soft
  bool toggleSoft(String s) {
    if (softSkills.contains(s)) {
      _n(() => softSkills.remove(s));
      return true;
    }
    if (softSkills.length >= maxSoftSkills) return false;
    _n(() => softSkills.add(s));
    return true;
  }

  void toggleDomain(String d) => _n(() => domains.contains(d) ? domains.remove(d) : domains.add(d));
  void setBackground(String v) => _n(() => background = v);
  bool get softValid => softSkills.isNotEmpty;

  // Docs
  void setResume(String? n, {int size = 0, Uint8List? bytes}) => _n(() {
        resumeName = n;
        resumeSize = n == null ? 0 : size;
        resumeBytes = n == null ? null : bytes;
      });
  void setLinks({String? portfolioUrl, String? linkedinUrl, String? github}) => _n(() {
        portfolio = portfolioUrl ?? portfolio;
        linkedin = linkedinUrl ?? linkedin;
        githubUrl = github ?? githubUrl;
      });

  // ── GitHub flow
  void setAnalysis(GithubAnalysis a) => _n(() {
        analysis = a;
        githubUrl = githubUrl.isEmpty ? 'https://github.com/${a.username}' : githubUrl;
      });
  void markGithubConnected() => _n(() => githubConnected = true);

  void addDetected(DetectedSkill s) => _n(() {
        s.status = SkillStatus.added;
        verifiedSkills.add(s.name);
      });
  void undoDetected(DetectedSkill s) => _n(() {
        s.status = SkillStatus.suggested;
        verifiedSkills.remove(s.name);
      });
  void dismissDetected(DetectedSkill s) => _n(() => s.status = SkillStatus.dismissed);
  void addAllDetected() {
    for (final s in analysis?.skills ?? <DetectedSkill>[]) {
      if (s.status == SkillStatus.suggested) addDetected(s);
    }
  }

  List<DetectedSkill> get pendingSuggestions => (analysis?.skills ?? []).where((s) => s.status == SkillStatus.suggested).toList();
  int get addedCount => (analysis?.skills ?? []).where((s) => s.status == SkillStatus.added).length;

  /// Analysis data is removed, skills already added stay verified.
  void disconnectGithub() => _n(() {
        githubConnected = false;
        analysis = null;
        githubUrl = '';
      });

  // ── Why Continue is blocked (null = OK)
  String? get basicBlockedReason => displayName.trim().isEmpty
      ? 'Enter your display name to continue'
      : username.trim().length < 3
          ? 'Username must be at least 3 characters'
          : null;
  String? get technicalBlockedReason => track == null
      ? 'Pick your main engineering track'
      : level == null
          ? 'Choose your experience level'
          : languages.isEmpty
              ? 'Select at least one programming language'
              : null;
  String? get softBlockedReason => softSkills.isEmpty ? 'Pick at least one soft skill' : null;
  String? get resumeBlockedReason => resumeName == null ? 'Upload your résumé (tap the Upload PDF box) to continue' : null;

  // ── Completion
  List<ChecklistItem> get checklist => [
        ChecklistItem('Basic Info', 'Bio, title, location & timezone', basicValid),
        ChecklistItem('Track & Experience Level', track != null && level != null ? '$track • $level' : 'Your discipline and seniority', track != null && level != null),
        ChecklistItem('Languages & Frameworks', languages.isNotEmpty ? [...languages.keys, ...frameworks].take(4).join(', ') : 'Your core toolset', languages.isNotEmpty),
        ChecklistItem('Soft Skills & Interests', softSkills.isNotEmpty ? softSkills.take(2).join(', ') : 'How you collaborate', softSkills.isNotEmpty),
        ChecklistItem('Curriculum Vitae / Résumé', resumeName ?? 'Upload your PDF résumé', resumeName != null),
        ChecklistItem('Portfolio Link', portfolio.trim().isNotEmpty ? portfolio : 'Showcase your best work', portfolio.trim().isNotEmpty),
        ChecklistItem('LinkedIn Link', linkedin.trim().isNotEmpty ? linkedin : 'Expands your professional network', linkedin.trim().isNotEmpty),
        ChecklistItem('GitHub Connection', githubConnected ? '@${analysis?.username ?? 'connected'}' : 'Adds evidence for your skills from code', githubConnected),
      ];
  int get completedItems => checklist.where((e) => e.done).length;
  int get completion => (completedItems * 100 / checklist.length).round();

  List<String> get allSkills => {...languages.keys, ...frameworks, ...verifiedSkills}.toList();
}

class ChecklistItem {
  final String title, subtitle;
  final bool done;
  const ChecklistItem(this.title, this.subtitle, this.done);
}

String formatBytes(int b) {
  if (b <= 0) return '0 KB';
  if (b < 1024 * 1024) return '${(b / 1024).toStringAsFixed(0)} KB';
  return '${(b / (1024 * 1024)).toStringAsFixed(1)} MB';
}
