import 'package:equatable/equatable.dart';

// What the "project is live" screen needs after publishing.
class PublishResult extends Equatable {
  const PublishResult({
    required this.projectId,
    required this.matchedDevelopers,
    required this.urgentTrackName,
    required this.expertise,
  });
  final String projectId;
  final int matchedDevelopers;
  final String? urgentTrackName; // track with the most open spots
  final List<String> expertise; // skills used for the matching text

  // Fields used for equality.
  @override
  List<Object?> get props => [projectId, matchedDevelopers, urgentTrackName, expertise];
}