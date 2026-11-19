import 'package:devsync/features/create_project/data/model/publish_result.dart';
import 'package:equatable/equatable.dart';

// Publish flow: initial -> loading -> success | failure.
abstract class PublishState extends Equatable {
  const PublishState();

  @override
  List<Object?> get props => [];
}

// Nothing published yet.
class PublishInitial extends PublishState {
  const PublishInitial();
}

// Request in progress.
class PublishLoading extends PublishState {
  const PublishLoading();
}

// Project is live.
class PublishSuccess extends PublishState {
  const PublishSuccess(this.result);

  final PublishResult result;

  @override
  List<Object?> get props => [result];
}

// Something went wrong.
class PublishFailure extends PublishState {
  const PublishFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
