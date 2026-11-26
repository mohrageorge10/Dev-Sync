import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/networking/errors/firebase_error_handler.dart';
import 'package:devsync/features/create_project/data/repositories/project_repository.dart';
import 'package:devsync/features/create_project/presentation/cubit/draft/draft_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/publish/publish_state.dart';
import 'package:devsync/features/create_project/presentation/cubit/team/team_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/my_projects/presentation/cubit/my_projects_cubit.dart';
import 'package:devsync/features/my_teams/data/app_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Handles saving draft, publishing project, and syncing dependent app controllers.
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

  // Save draft without publishing and refresh My Projects.
  Future<String?> saveDraft() async {
    try {
      _draftProjectId = await _repository.saveDraft(
        _draftCubit.state.draft,
        _teamCubit.state.tracks,
        existingProjectId: _draftProjectId,
      );
      if (ServiceLocator.isRegistered<MyProjectsCubit>()) {
        ServiceLocator.get<MyProjectsCubit>().loadData();
      }
      return null;
    } catch (e) {
      return FirebaseErrorHandler.handle(e);
    }
  }

  // Publish project to Firestore and refresh My Projects, My Teams, and Discover.
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
      if (ServiceLocator.isRegistered<MyProjectsCubit>()) {
        ServiceLocator.get<MyProjectsCubit>().loadData();
      }
      if (ServiceLocator.isRegistered<TeamsController>()) {
        ServiceLocator.get<TeamsController>().loadData(force: true);
      }
      if (ServiceLocator.isRegistered<DiscoverCubit>()) {
        ServiceLocator.get<DiscoverCubit>().loadData();
      }
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
