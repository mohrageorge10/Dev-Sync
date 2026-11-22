import 'package:flutter/material.dart';

/// Picks an icon for a skill name ("Flutter", "REST APIs", "BLE"...).
/// Used by the AI Match screens so every skill gets a meaningful icon.
IconData skillIconFor(
  String skill, {
  IconData fallback = Icons.layers_outlined,
}) {
  final s = skill.toLowerCase();
  bool has(String pattern) => RegExp(pattern).hasMatch(s);

  if (has(r'\b(ble|bluetooth)\b')) return Icons.bluetooth_rounded;
  if (has(r'sensor|telemetry|iot|time-?series')) return Icons.sensors_rounded;
  if (has(r'flutter')) return Icons.verified_outlined;
  if (has(r'\b(dart|kotlin|swift|java|python|javascript|typescript|go|rust)\b')) {
    return Icons.code_rounded;
  }
  if (has(r'\bapis?\b|\brest\b|graphql|\bhttps?\b|grpc')) return Icons.api_rounded;
  if (has(r'\bgit\b|github|gitlab|version control')) {
    return Icons.call_split_rounded;
  }
  if (has(r'sql|sqlite|database|firebase|firestore|mongo|cache|storage')) {
    return Icons.storage_rounded;
  }
  if (has(r'riverpod|bloc|provider|state')) return Icons.account_tree_outlined;
  if (has(r'\btest(s|ing)?\b|\bqa\b')) return Icons.bug_report_outlined;
  if (has(r'\b(design|ui|ux|figma)\b')) return Icons.palette_outlined;
  if (has(r'docker|aws|cloud|ci/?cd|devops')) return Icons.cloud_outlined;
  if (has(r'\bai\b|machine learning|\bml\b|tensorflow')) {
    return Icons.psychology_outlined;
  }
  return fallback;
}

/// Icon of one "Mentorship & Growth Highlights" row.
IconData highlightIconFor(String title, int index) {
  final t = title.toLowerCase();
  if (RegExp(r'review|mentor|maintainer|pair').hasMatch(t)) {
    return Icons.person_outline_rounded;
  }
  if (RegExp(r'hardware|byte|stream|communication|protocol').hasMatch(t)) {
    return Icons.memory_rounded;
  }
  if (RegExp(r'throughput|speed|performance|scale|data').hasMatch(t)) {
    return Icons.speed_rounded;
  }
  const fallback = [
    Icons.person_outline_rounded,
    Icons.memory_rounded,
    Icons.speed_rounded,
  ];
  return fallback[index % fallback.length];
}

/// Icon of a recommended project, guessed from its title / description.
IconData projectIconFor(String title, [String description = '']) {
  final t = '$title $description'.toLowerCase();
  bool has(String pattern) => RegExp(pattern).hasMatch(t);

  if (has(r'\beco|carbon|green|climate|sustain')) return Icons.eco_outlined;
  if (has(r'\bcli\b|terminal|command|devtool|devops')) {
    return Icons.terminal_rounded;
  }
  if (has(r'neur(al|o)|machine learning|\bai\b|\bml\b|tensorflow|vision|nlp')) {
    return Icons.psychology_outlined;
  }
  if (has(r'game')) return Icons.sports_esports_outlined;
  if (has(r'\bshop|commerce|\bstore\b|market')) return Icons.shopping_bag_outlined;
  if (has(r'health|fitness|medical')) return Icons.favorite_border_rounded;
  if (has(r'chat|message|social')) return Icons.chat_bubble_outline_rounded;
  if (has(r'analytics|dashboard|metrics|insight')) return Icons.insights_rounded;
  if (has(r'\bweb\b|website|frontend')) return Icons.language_rounded;
  if (has(r'mobile|\bapp\b')) return Icons.smartphone_rounded;
  return Icons.rocket_launch_outlined;
}
