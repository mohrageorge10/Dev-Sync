import 'package:devsync/core/networking/errors/firebase_error_handler.dart';
import 'package:devsync/features/create_project/data/repositories/project_repository.dart';
import 'package:devsync/features/create_project/presentation/cubit/draft/draft_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/publish/publish_state.dart';
import 'package:devsync/features/create_project/presentation/cubit/team/team_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Handles saving draft and publishing project.
class PublishCubit extends Cubit<PublishState> {
  PublishCubit({
    required ProjectRepository repository,
    required DraftCubit draftCubit,
    required TeamCubit teamCubit,
  })  : _repository = repository,
        _draftCubit = draftCubit,
        _teamCubit = teamCubit,
        super(const PublishInitial());

  final ProjectRepository _repository;
  final DraftCubit _draftCubit;
  final TeamCubit _teamCubit;
  String? _draftProjectId;

  // Save draft without publishing.
  Future<String?> saveDraft() async {
    try {
      _draftProjectId = await _repository.saveDraft(
        _draftCubit.state.draft,
        _teamCubit.state.tracks,
        existingProjectId: _draftProjectId,
      );
      return null;
    } catch (e) {
      return FirebaseErrorHandler.handle(e);
    }
  }

  // Publish project to Firestore.
  Future<void> publish() async {
    emit(const PublishLoading());
    try {
      final result = await _repository.publish(
        _draftCubit.state.draft,
        _teamCubit.state.tracks,
        existingProjectId: _draftProjectId,
      );
      if (isClosed) return;
      _draftProjectId = null;
      emit(PublishSuccess(result));
    } catch (e) {
      if (isClosed) return;
      emit(PublishFailure(FirebaseErrorHandler.handle(e)));
    }
  }

  void reset() {
    _draftProjectId = null;
    emit(const PublishInitial());
  }
}
