import 'package:flutter/material.dart';

// Portfolio project item model displayed on public developer profiles.
class PortfolioProjectData {
  final String projectId;
  final String badgeText;
  final String statusText;
  final IconData topIcon;
  final String title;
  final String description;
  final String completionSummary;
  final String roleText;
  final IconData trailingInfoIcon;
  final String trailingInfoText;
  final String logoUrl;
  final String productUrl;
  final String repoUrl;
  final String period;
  final List<String> tags;
  final List<String> awards;
  final bool isCompleted;

  const PortfolioProjectData({
    this.projectId = '',
    required this.badgeText,
    required this.statusText,
    required this.topIcon,
    required this.title,
    required this.description,
    this.completionSummary = '',
    required this.roleText,
    required this.trailingInfoIcon,
    required this.trailingInfoText,
    this.logoUrl = '',
    this.productUrl = '',
    this.repoUrl = '',
    this.period = '',
    this.tags = const [],
    this.awards = const [],
    this.isCompleted = false,
  });
}

// Empty default (real projects are loaded from Firestore).
const List<PortfolioProjectData> portfolioProjects = [];
