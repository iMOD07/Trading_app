part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileSuccess extends ProfileState {
  final String message;
  const ProfileSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ProfileFailure extends ProfileState {
  final String error;
  const ProfileFailure(this.error);

  @override
  List<Object> get props => [error];
}
