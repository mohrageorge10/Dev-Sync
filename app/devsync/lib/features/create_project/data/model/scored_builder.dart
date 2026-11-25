
import 'package:devsync/features/create_project/data/model/dev_builder.dart';
import 'package:devsync/features/create_project/data/model/slot_match.dart';
import 'package:equatable/equatable.dart';
// A search result: the builder + the slot that fits him best.
class ScoredBuilder extends Equatable {
  const ScoredBuilder(this.builder, this.slot);

  final DevBuilder builder;
  final SlotMatch slot;

  // Match percentage shown in the list.
  int get percent => slot.percent;

  // Fields used for equality.
  @override
  List<Object?> get props => [builder, slot];
}
