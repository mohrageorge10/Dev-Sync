// Featured Behance project / case study item added by a designer.
class BehanceShot {
  const BehanceShot({
    required this.title,
    required this.url,
    this.coverUrl = '',
  });

  final String title;
  final String url;
  final String coverUrl;

  Map<String, dynamic> toMap() => {
    'title': title.trim(),
    'url': url.trim(),
    'coverUrl': coverUrl.trim(),
  };

  factory BehanceShot.fromMap(Map<String, dynamic> map) => BehanceShot(
    title: (map['title'] ?? '').toString().trim(),
    url: (map['url'] ?? '').toString().trim(),
    coverUrl: (map['coverUrl'] ?? '').toString().trim(),
  );
}

// Connected Behance portfolio metadata for UI/UX designers.
class BehanceProfile {
  const BehanceProfile({
    required this.username,
    this.tools = const [],
    this.shots = const [],
  });

  final String username;
  final List<String> tools;
  final List<BehanceShot> shots;

  String get profileUrl => 'https://www.behance.net/$username';

  // Extract a clean Behance username from a handle or full behance.net URL.
  static String extractUsername(String raw) {
    var v = raw.trim();
    if (v.isEmpty) return '';
    v = v.replaceFirst(RegExp(r'^https?://(www\.)?behance\.net/'), '');
    if (v.startsWith('@')) v = v.substring(1);
    final slashIdx = v.indexOf('/');
    if (slashIdx != -1) v = v.substring(0, slashIdx);
    return v.trim();
  }

  Map<String, dynamic> toFirestoreMap() => {
    'username': username,
    'profileUrl': profileUrl,
    'tools': tools,
    'shots': shots.map((s) => s.toMap()).toList(),
  };

  factory BehanceProfile.fromFirestoreMap(Map<String, dynamic> map) {
    final rawTools = map['tools'];
    final rawShots = map['shots'];
    return BehanceProfile(
      username: (map['username'] ?? '').toString().trim(),
      tools: rawTools is Iterable
          ? rawTools
                .map((e) => e.toString().trim())
                .where((e) => e.isNotEmpty)
                .toList()
          : const [],
      shots: rawShots is Iterable
          ? rawShots
                .whereType<Map>()
                .map((m) => BehanceShot.fromMap(Map<String, dynamic>.from(m)))
                .where((s) => s.title.isNotEmpty)
                .toList()
          : const [],
    );
  }
}
