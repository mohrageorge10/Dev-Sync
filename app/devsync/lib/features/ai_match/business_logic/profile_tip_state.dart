import 'package:equatable/equatable.dart';

/// What the "Complete your profile" banner shows.
class ProfileTipState extends Equatable {
  const ProfileTipState({
    this.visible = false,
    this.percent,
    this.signedIn = true,
  });

  final bool visible;

  /// "68% Calibrated" tag (null = hidden).
  final int? percent;
  final bool signedIn;

  @override
  List<Object?> get props => [visible, percent, signedIn];
}
