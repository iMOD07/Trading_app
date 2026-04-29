import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Backend currently has no /api/auth/update endpoint.
/// This bloc is kept as a placeholder so existing UI compiles.
/// When the backend adds password-change support, wire it here.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileUpdateSubmitted>(_onUpdateSubmitted);
  }

  Future<void> _onUpdateSubmitted(
      ProfileUpdateSubmitted event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    // Backend endpoint does not exist yet — return clear failure.
    emit(const ProfileFailure(
        'Profile update is not available yet. Please contact admin.'));
  }
}
