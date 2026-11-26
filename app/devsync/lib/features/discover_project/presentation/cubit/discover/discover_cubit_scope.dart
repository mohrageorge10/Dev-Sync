import 'package:devsync/core/di/service_locator.dart';
import 'package:devsync/features/discover_project/presentation/cubit/discover/discover_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Provides the shared DiscoverCubit across discover screens without closing the singleton.
class DiscoverCubitScope extends StatelessWidget {
  const DiscoverCubitScope({
    super.key,
    required this.child,
    this.initialTab,
  });

  final Widget child;
  final int? initialTab;

  @override
  Widget build(BuildContext context) {
    if (ServiceLocator.isRegistered<DiscoverCubit>()) {
      final cubit = ServiceLocator.get<DiscoverCubit>();
      if (initialTab != null && cubit.state.tab != initialTab) {
        cubit.setTab(initialTab!);
      }
      return BlocProvider.value(value: cubit, child: child);
    }

    return BlocProvider(
      create: (_) => DiscoverCubit(initialTab: initialTab ?? 0),
      child: child,
    );
  }
}
