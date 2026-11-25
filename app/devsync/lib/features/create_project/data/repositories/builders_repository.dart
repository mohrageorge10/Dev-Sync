import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/dev_builder.dart';

abstract class BuildersRepository {
  List<DevBuilder> get pool;
  Future<List<DevBuilder>> search(String query);
}

// Firestore users repository with mock fallback.
class FirestoreBuildersRepository implements BuildersRepository {
  FirestoreBuildersRepository({
    required FirestoreService firestoreService,
    required FirebaseAuthService authService,
    BuildersRepository? fallback,
  })  : _firestore = firestoreService,
        _auth = authService,
        _fallback = fallback ?? MockBuildersRepository();

  final FirestoreService _firestore;
  final FirebaseAuthService _auth;
  final BuildersRepository _fallback;
  List<DevBuilder>? _cachedPool;

  @override
  List<DevBuilder> get pool =>
      (_cachedPool != null && _cachedPool!.isNotEmpty) ? _cachedPool! : _fallback.pool;

  Future<List<DevBuilder>> _loadPool() async {
    try {
      final docs = await _firestore.getCollection(
        collectionPath: FirebaseConstants.usersCollection,
      );
      final uid = _auth.currentUserId;
      final loaded = docs
          .map(DevBuilder.fromFirestore)
          .where((b) => b.id.isNotEmpty && b.id != uid)
          .toList();
      if (loaded.isNotEmpty) return _cachedPool = loaded;
    } catch (_) {}
    return _fallback.pool;
  }

  @override
  Future<List<DevBuilder>> search(String query) async {
    final source = await _loadPool();
    return _filterBuilders(source, query);
  }
}

// Local mock builders repository.
class MockBuildersRepository implements BuildersRepository {
  @override
  final pool = const [
    DevBuilder(id: 'uid_1', name: 'Sarah Lin', publicId: 'sarahlin_dev', track: UserTrack.uiux, level: UserLevel.advanced, skills: ['Figma', 'Prototyping', 'Design Systems']),
    DevBuilder(id: 'uid_2', name: 'Sarah Connor', publicId: 'sarahc_ml', track: UserTrack.ai, level: UserLevel.advanced, skills: ['Python', 'PyTorch', 'LLMs']),
    DevBuilder(id: 'uid_3', name: 'Alex Chen', publicId: 'alexchen', track: UserTrack.mobile, level: UserLevel.intermediate, skills: ['Dart', 'Flutter', 'Firebase']),
    DevBuilder(id: 'uid_4', name: 'Mona Hassan', publicId: 'mona_h', track: UserTrack.mobile, level: UserLevel.intermediate, skills: ['Dart', 'State Management', 'Firebase']),
    DevBuilder(id: 'uid_5', name: 'Omar Khaled', publicId: 'omar_k', track: UserTrack.backend, level: UserLevel.advanced, skills: ['Go', 'PostgreSQL', 'Redis']),
    DevBuilder(id: 'uid_6', name: 'Tom Reed', publicId: 'tomreed', track: UserTrack.backend, level: UserLevel.junior, skills: ['Node.js', 'GraphQL'], availableNow: false),
    DevBuilder(id: 'uid_7', name: 'Lina Park', publicId: 'linapark', track: UserTrack.web, level: UserLevel.intermediate, skills: ['React', 'TypeScript', 'Tailwind']),
    DevBuilder(id: 'uid_8', name: 'Yusuf Demir', publicId: 'yusuf_ops', track: UserTrack.devops, level: UserLevel.advanced, skills: ['Docker', 'Kubernetes', 'CI/CD']),
    DevBuilder(id: 'uid_9', name: 'Nora Ali', publicId: 'nora_qa', track: UserTrack.qa, level: UserLevel.intermediate, skills: ['Cypress', 'Jest', 'Appium']),
    DevBuilder(id: 'uid_10', name: 'Karim Nabil', publicId: 'karim_n', track: UserTrack.data, level: UserLevel.junior, skills: ['Python', 'SQL', 'Machine Learning']),
    DevBuilder(id: 'uid_11', name: 'Dina Samy', publicId: 'dina_ux', track: UserTrack.uiux, level: UserLevel.intermediate, skills: ['Figma', 'User Research', 'Motion']),
    DevBuilder(id: 'uid_12', name: 'Ivy Zhang', publicId: 'ivyz', track: UserTrack.ai, level: UserLevel.advanced, skills: ['LangChain', 'HuggingFace', 'Vector DBs']),
  ];

  @override
  Future<List<DevBuilder>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _filterBuilders(pool, query);
  }
}

// Filter builders by name, handle, track, or skill.
List<DevBuilder> _filterBuilders(List<DevBuilder> source, String query) {
  final q = query.trim().toLowerCase().replaceFirst('@', '');
  if (q.isEmpty) return source.take(8).toList();
  return source
      .where((b) =>
          b.name.toLowerCase().contains(q) ||
          b.publicId.toLowerCase().contains(q) ||
          b.track.name.toLowerCase().contains(q) ||
          b.skills.any((s) => s.toLowerCase().contains(q)))
      .toList();
}
