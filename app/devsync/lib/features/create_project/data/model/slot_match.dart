import 'package:devsync/features/create_project/data/model/team_track.dart';
import 'package:equatable/equatable.dart';

// A builder matched with the best open slot for him.
class SlotMatch extends Equatable {
  const SlotMatch(this.track, this.percent);

  final TeamTrack track;
  final int percent;

  // Fields used for equality.
  @override
  List<Object?> get props => [track, percent];
}
