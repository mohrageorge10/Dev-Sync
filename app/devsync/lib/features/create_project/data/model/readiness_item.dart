import 'package:equatable/equatable.dart';

// One line of the launch checklist.
class ReadinessItem extends Equatable {
  const ReadinessItem(this.label, this.done, {this.required = true});

  final String label;
  final bool done;
  final bool required; // required items block publishing

  // Fields used for equality.
  @override
  List<Object?> get props => [label, done, required];
}
