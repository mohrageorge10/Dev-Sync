import 'package:flutter/material.dart';

// Portfolio project item model.
class PortfolioProjectData {
  final String badgeText;
  final String statusText;
  final IconData topIcon;
  final String title;
  final String description;
  final String roleText;
  final IconData trailingInfoIcon;
  final String trailingInfoText;

  const PortfolioProjectData({
    required this.badgeText,
    required this.statusText,
    required this.topIcon,
    required this.title,
    required this.description,
    required this.roleText,
    required this.trailingInfoIcon,
    required this.trailingInfoText,
  });
}

// Default portfolio projects for public profiles.
const List<PortfolioProjectData> portfolioProjects = [
  PortfolioProjectData(
    badgeText: 'REAL-WORLD',
    statusText: 'Active',
    topIcon: Icons.eco_outlined,
    title: 'EcoTrack Mobile',
    description:
        'IoT telemetry capture and real-time carbon emissions analytics.',
    roleText: 'Mobile Lead',
    trailingInfoIcon: Icons.group_outlined,
    trailingInfoText: '5 members',
  ),
  PortfolioProjectData(
    badgeText: 'LEARNING',
    statusText: 'Active',
    topIcon: Icons.account_tree_outlined,
    title: 'AlgoVisualizer Mobile',
    description:
        'Interactive data structure and algorithm animation tool for students.',
    roleText: 'Contributor',
    trailingInfoIcon: Icons.star_outline_rounded,
    trailingInfoText: '120 stars',
  ),
];