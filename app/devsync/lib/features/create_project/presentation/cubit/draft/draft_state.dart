import 'package:devsync/features/create_project/data/model/project_draft.dart';
import 'package:equatable/equatable.dart';

// State of step 1: just the draft the user is editing.
class DraftState extends Equatable {
  const DraftState({this.draft = const ProjectDraft()});

  final ProjectDraft draft;

  // Fields used for equality.
  @override
  List<Object?> get props => [draft];
}
