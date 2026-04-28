part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

class ProfileLoaded extends ProfileEvent {
  const ProfileLoaded();
}

class ProfileUpdateSubmitted extends ProfileEvent {
  final String username;
  final String? password;

  const ProfileUpdateSubmitted({
    required this.username,
    this.password,
  });

  @override
  List<Object> get props => [username];
}
