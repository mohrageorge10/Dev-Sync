import 'package:flutter/material.dart';
import 'profile_routes.dart';
import 'package:devsync/feature/profile/presentation/screens/github/analysis_screen.dart';
import 'package:devsync/feature/profile/presentation/screens/basic_info_screen.dart';
import 'package:devsync/feature/profile/presentation/screens/complete_profile_screen.dart';
import 'package:devsync/feature/profile/presentation/screens/github/connect_github_screen.dart';
import 'package:devsync/feature/profile/presentation/screens/connect_work_screen.dart';
import 'package:devsync/feature/profile/presentation/screens/developer_snapshot_screen.dart';
import 'package:devsync/feature/profile/presentation/screens/explore_projects_screen.dart';
import 'package:devsync/feature/profile/presentation/screens/project_interests_screen.dart';
import 'package:devsync/feature/profile/presentation/screens/github/review_skills_screen.dart';
import 'package:devsync/feature/profile/presentation/screens/skills_expertise_screen.dart';
import 'package:devsync/feature/profile/presentation/screens/technical_profile_screen.dart';

/// يبني شاشة الـ Profile المناسبة لكل route.
class ProfileRouter {
  static Route<dynamic> generate(RouteSettings s) {
    final Widget page = switch (s.name) {
      ProfileRoutes.basicInfo => const BasicInfoScreen(),
      ProfileRoutes.technical => const TechnicalProfileScreen(),
      ProfileRoutes.skills => const SkillsExpertiseScreen(),
      ProfileRoutes.projects => const ProjectInterestsScreen(),
      ProfileRoutes.connectWork => const ConnectWorkScreen(),
      ProfileRoutes.complete => const CompleteProfileScreen(),
      ProfileRoutes.snapshot => const DeveloperSnapshotScreen(),
      ProfileRoutes.explore => const ExploreProjectsScreen(),
      ProfileRoutes.githubConnect => const ConnectGithubScreen(),
      ProfileRoutes.githubAnalysis => const AnalysisScreen(),
      ProfileRoutes.githubReview => const ReviewSkillsScreen(),
      _ => const BasicInfoScreen(),
    };
    return MaterialPageRoute(settings: s, builder: (_) => page);
  }
}
