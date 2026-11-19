import 'package:devsync/features/create_project/data/model/readiness_item.dart';
import 'package:equatable/equatable.dart';

// Values derived from the draft + the team (score, tip, checklist, stack).
class InsightsState extends Equatable {
  const InsightsState({
    required this.strength,
    required this.tip,
    required this.checklist,
    required this.techStack,
  });

  final int strength; // 0..100
  final String tip;
  final List<ReadinessItem> checklist;
  final List<String> techStack;

  // Text label of the score.
  String get label =>
      strength >= 80 ? 'Outstanding' : (strength >= 50 ? 'Getting there' : 'Needs detail');

  // Publishing is allowed when every required item is done.
  bool get canPublish => checklist.where((i) => i.required).every((i) => i.done);

  // Fields used for equality.
  @override
  List<Object?> get props => [strength, tip, checklist, techStack];
}
