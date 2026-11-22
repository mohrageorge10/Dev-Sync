import 'dart:async';

import 'package:devsync/features/ai_match/business_logic/profile_tip_state.dart';
import 'package:devsync/features/ai_match/data/repos/profile_tip_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Decides if the "Complete your profile" banner is shown, and its percent.
///  - signed out            -> shown, no percent
///  - signed in, < 100%     -> shown, with "N% Calibrated"
///  - complete or dismissed -> hidden
class ProfileTipCubit extends Cubit<ProfileTipState> {
  ProfileTipCubit(this._repo, {Stream<String?>? userIdChanges})
      : super(const ProfileTipState()) {
    // Login / logout -> read the profile again.
    _sub = userIdChanges?.distinct().skip(1).listen((_) => load());
  }

  final ProfileTipRepo _repo;
  StreamSubscription<String?>? _sub;

  Future<void> load() async {
    try {
      final info = await _repo.load();
      if (isClosed) return;
      if (!info.signedIn) {
        emit(const ProfileTipState(visible: true, signedIn: false));
        return;
      }
      final percent = info.calibration;
      emit(ProfileTipState(
        visible: percent != null && percent < 100 && !info.dismissed,
        percent: percent,
      ));
    } catch (_) {
      if (!isClosed) emit(const ProfileTipState());
    }
  }

  Future<void> dismiss() async {
    emit(ProfileTipState(
      visible: false,
      percent: state.percent,
      signedIn: state.signedIn,
    ));
    try {
      await _repo.dismiss();
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
