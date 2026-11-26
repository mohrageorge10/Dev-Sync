import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/core/shared/nav_bar/app_bottom_nav_bar.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit_scope.dart';
import 'package:devsync/features/discover_project/presentation/screens/home_screen.dart';
import 'package:devsync/features/discover_project/presentation/screens/saved_screen.dart';
import 'package:devsync/features/my_projects/presentation/cubit/my_projects_cubit.dart';
import 'package:devsync/features/my_projects/presentation/screens/my_projects_screen.dart';
import 'package:devsync/features/my_teams/data/app_state.dart';
import 'package:devsync/features/my_teams/presentation/screens/my_teams_screen.dart';
import 'package:devsync/features/profile/presentation/screens/profile_tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Main app shell for authenticated users.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (ServiceLocator.isRegistered<DiscoverCubit>()) {
      ServiceLocator.get<DiscoverCubit>().loadData();
    }
    if (ServiceLocator.isRegistered<TeamsController>()) {
      ServiceLocator.get<TeamsController>().loadData();
    }
    if (ServiceLocator.isRegistered<MyProjectsCubit>()) {
      ServiceLocator.get<MyProjectsCubit>().loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DiscoverCubitScope(
      child: Builder(
        builder: (shellContext) {
          final screens = [
            const HomeScreen(),
            BlocProvider.value(
              value: ServiceLocator.get<MyProjectsCubit>(),
              child: const MyProjectsScreen(embedded: true),
            ),
            TeamsScope(
              controller: ServiceLocator.get<TeamsController>(),
              child: const MyTeamsScreen(embedded: true),
            ),
            const SavedScreen(),
            ProfileTabScreen(
              onProfileUpdated: () =>
                  shellContext.read<DiscoverCubit>().loadData(),
            ),
          ];

          return Scaffold(
            body: IndexedStack(index: _currentIndex, children: screens),
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          );
        },
      ),
    );
  }
}
