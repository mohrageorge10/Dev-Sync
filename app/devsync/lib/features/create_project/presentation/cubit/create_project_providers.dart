import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/features/create_project/data/repositories/builders_repository.dart';
import 'package:devsync/features/create_project/data/repositories/project_repository.dart';
import 'package:devsync/features/create_project/presentation/cubit/draft/draft_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/insights/insights_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/publish/publish_cubit.dart';
import 'package:devsync/features/create_project/presentation/cubit/team/team_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Scoped repositories and cubits for the create project flow.
class CreateProjectProviders extends StatelessWidget {
  const CreateProjectProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Repositories from ServiceLocator.
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<BuildersRepository>(
          create: (_) => ServiceLocator.isRegistered<BuildersRepository>()
              ? ServiceLocator.get<BuildersRepository>()
              : MockBuildersRepository(),
        ),
        RepositoryProvider<ProjectRepository>(
          create: (context) => ServiceLocator.isRegistered<ProjectRepository>()
              ? ServiceLocator.get<ProjectRepository>()
              : MockProjectRepository(context.read<BuildersRepository>()),
        ),
      ],

      // Cubits shared by the whole flow.
      child: MultiBlocProvider(
        providers: [
          BlocProvider<DraftCubit>(create: (_) => DraftCubit()),
          BlocProvider<TeamCubit>(create: (_) => TeamCubit()),
          BlocProvider<InsightsCubit>(
            create: (context) => InsightsCubit(
              draftCubit: context.read<DraftCubit>(),
              teamCubit: context.read<TeamCubit>(),
            ),
          ),
          BlocProvider<PublishCubit>(
            create: (context) => PublishCubit(
              repository: context.read<ProjectRepository>(),
              draftCubit: context.read<DraftCubit>(),
              teamCubit: context.read<TeamCubit>(),
            ),
          ),
        ],
        child: child,
      ),
    );
  }
}

// Reset all create project cubits.
VoidCallback projectFlowResetter(BuildContext context) {
  final draft = context.read<DraftCubit>();
  final team = context.read<TeamCubit>();
  final publish = context.read<PublishCubit>();
  return () {
    draft.reset();
    team.reset();
    publish.reset();
  };
}
