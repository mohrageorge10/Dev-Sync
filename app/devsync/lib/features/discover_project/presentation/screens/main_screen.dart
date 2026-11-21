import 'package:devsync/core/routing/app_routes.dart';
import 'package:devsync/core/shared/nav_bar/app_bottom_nav_bar.dart';
import 'package:devsync/core/theme/app_colors.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit_scope.dart';
import 'package:devsync/features/discover_project/presentation/screens/home_screen.dart';
import 'package:devsync/features/discover_project/presentation/screens/saved_screen.dart';
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

  static const List<Widget> _screens = [
    HomeScreen(),
    Scaffold(body: Center(child: Text('My Projects Screen'))),
    Scaffold(body: Center(child: Text('My Teams Screen'))),
    SavedScreen(),
    Scaffold(body: Center(child: Text('Profile Screen'))),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return DiscoverCubitScope(
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _screens),
        floatingActionButton: Builder(
          builder: (fabContext) => FloatingActionButton(
            backgroundColor: c.primary,
            foregroundColor: c.onPrimary,
            tooltip: 'Create Project',
            onPressed: () async {
              await Navigator.of(fabContext).pushNamed(AppRoutes.createProject);
              if (fabContext.mounted) {
                fabContext.read<DiscoverCubit>().loadData();
              }
            },
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
