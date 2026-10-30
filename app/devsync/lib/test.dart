import 'package:devsync/core/constants/app_constants.dart';
import 'package:devsync/core/database/cache.dart';
import 'package:devsync/core/shared/badges/app_badge.dart';
import 'package:devsync/core/shared/buttons/app_primary_button.dart';
import 'package:devsync/core/shared/buttons/app_secondary_button.dart';
import 'package:devsync/core/shared/buttons/app_text_button.dart';
import 'package:devsync/core/shared/cards/app_developer_card.dart';
import 'package:devsync/core/shared/cards/app_project_card.dart';
import 'package:devsync/core/shared/chips/app_skill_chip.dart';
import 'package:devsync/core/shared/input_fields/app_input_field.dart';
import 'package:devsync/core/shared/selectors/app_dropdown_field.dart';
import 'package:devsync/core/shared/tap_bars/app_segmented_control.dart';
import 'package:devsync/core/shared/tap_bars/app_tab_bar.dart';
import 'package:devsync/core/utils/validators.dart';
import 'package:flutter/material.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  final emailController = TextEditingController();
  final repoController = TextEditingController();
  int filter = 0;
  int tab = 0;

  String? role;

  final skills = ['Flutter', 'Dart', 'Python', 'GraphQL', 'Firebase'];
  final selected = <String>{'Flutter', 'Firebase'};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: 20,
            children: [
              AppPrimaryButton(
                onPressed: () {
                  print("done");
                },
                buttonText: "go to home",
                trailingIcon: Icons.arrow_back,
                isDisabled: false,
              ),

              AppSecondaryButton(
                onPressed: () {
                  print("go");
                },
                buttonText: "go",
                leadingIcon: Icons.save,
              ),

              AppTextButton(
                onPressed: () {
                  print("text");
                },
                buttonText: "text",
                leadingIcon: Icons.favorite,
              ),

              AppInputField(
                controller: emailController,
                label: 'Commit Email',
                hint: 'dev@sync.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => AppValidators.validateEmail(val),
              ),

              AppInputField(
                controller: repoController,
                label: 'Repository URL',
                trailingLabel: 'Optional',
                hint: 'https://github.com/org/repo',
                prefixIcon: Icons.link_rounded,
              ),

              AppDropdownField<String>(
                label: 'Role Needed',
                hint: 'Select a role',
                prefixIcon: Icons.badge_outlined,
                value: role,
                items: const ['Full-Stack Flutter Engineer', 'UI/UX Designer'],
                itemLabel: (r) => r,
                onChanged: (v) => setState(() => role = v),
                validator: (v) => v == null ? 'Please select a role' : null,
              ),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final skill in skills)
                    AppSkillChip(
                      label: skill,
                      selected: selected.contains(skill),
                      onTap: () => setState(() {
                        selected.contains(skill)
                            ? selected.remove(skill)
                            : selected.add(skill);
                      }),
                    ),
                ],
              ),

              // Project Purpose
              Wrap(
                spacing: 8,
                children: [
                  AppBadge.learning(context),
                  AppBadge.realWorld(context),
                ],
              ),

              // Status badges
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppBadge.success(context, 'Open'),
                  AppBadge.info(context, 'Full'),
                  AppBadge.warning(context, 'Pending'),
                  AppBadge.success(context, 'Accepted'),
                  AppBadge.error(context, 'Declined'),
                ],
              ),

              AppProjectCard(
                title: 'EcoTrack Mobile: Carbon Analytics',
                description: 'Cross-platform mobile application for community carbon footprint tracking and local tree planting coordination.',
                skills: const ['Flutter', 'Riverpod', 'FastAPI'],
                members: 3,
                capacity: 5,
                matchPercent: 89,
                isRealWorld: true,
                onViewProject: () {},
              ),

              DeveloperProfileCard(
                name: 'Marcus Vance',
                username: 'marcusdev',
                title: 'Mobile Architect & Flutter Specialist',
                avatarUrl: 'https://example.com/marcus.jpg',
                skills: ['Dart', 'Flutter', 'Clean Architecture'],
                githubConnected: true,
                matchPercent: 96,
                matchReason: 'based on past open-source contributions.',
              ),

              AppSegmentedControl(
                labels: const ['All', 'Learning', 'Real-world'],
                selectedIndex: filter,
                onChanged: (i) => setState(() => filter = i),
              ),

              AppTabBar(
                labels: const ['Active Roles', 'Pending Invites', 'Archived'],
                selectedIndex: tab,
                badges: const {0: 4},
                onChanged: (i) => setState(() => tab = i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
