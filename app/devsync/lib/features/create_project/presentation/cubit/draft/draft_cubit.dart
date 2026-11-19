import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/services/firebase/firebase_auth_service.dart';
import 'package:devsync/core/services/firebase/firebase_constants.dart';
import 'package:devsync/core/services/firebase/firestore_service.dart';
import 'package:devsync/core/utils/devsync_enums.dart';
import 'package:devsync/features/create_project/data/model/enums.dart';
import 'package:devsync/features/create_project/data/model/project_draft.dart';
import 'package:devsync/features/create_project/presentation/cubit/draft/draft_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Step 1 project draft cubit.
class DraftCubit extends Cubit<DraftState> {
  DraftCubit() : super(const DraftState()) {
    _loadOwnerTrack();
  }

  UserTrack _ownerTrack = UserTrack.mobile;
  ProjectDraft get _draft => state.draft;

  void _update(ProjectDraft draft) => emit(DraftState(draft: draft));

  // Auto-resolve owner track from user profile.
  Future<void> _loadOwnerTrack() async {
    try {
      if (!ServiceLocator.isRegistered<FirebaseAuthService>() ||
          !ServiceLocator.isRegistered<FirestoreService>()) {
        return;
      }
      final uid = ServiceLocator.get<FirebaseAuthService>().currentUserId;
      if (uid == null) return;

      final doc = await ServiceLocator.get<FirestoreService>().getDocument(
        collectionPath: FirebaseConstants.usersCollection,
        docId: uid,
      );
      if (isClosed || doc == null) return;

      _ownerTrack = UserTrackX.fromName(
        doc[FirebaseConstants.fieldTrack]?.toString(),
      );
      _update(_draft.copyWith(ownerTrack: _ownerTrack));
    } catch (_) {}
  }

  void setTitle(String v) => _update(_draft.copyWith(title: v));

  void setDescription(String v) => _update(
        _draft.copyWith(
          description: v.length > ProjectDraft.maxDescription
              ? v.substring(0, ProjectDraft.maxDescription)
              : v,
        ),
      );

  void setPurpose(ProjectPurpose p) => _update(_draft.copyWith(purpose: p));

  void setDifficulty(ProjectDifficulty d) =>
      _update(_draft.copyWith(difficulty: d));

  void setExpectedEndDate(DateTime? date) => _update(
        date == null
            ? _draft.copyWith(clearExpectedEndDate: true)
            : _draft.copyWith(expectedEndDate: date),
      );

  void reset() => emit(DraftState(draft: ProjectDraft(ownerTrack: _ownerTrack)));
}
