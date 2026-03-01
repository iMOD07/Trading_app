part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

// Load user profile data
class ProfileLoaded extends ProfileEvent {
  const ProfileLoaded();
}

// Update user profile data
class ProfileUpdateSubmitted extends ProfileEvent {
  final String username;
  final String? password;
  final String? alpacaApiKey;
  final String? alpacaApiSecret;
  final String? alpacaBaseUrl;

  const ProfileUpdateSubmitted({
    required this.username,
    this.password,
    this.alpacaApiKey,
    this.alpacaApiSecret,
    this.alpacaBaseUrl,
  });

  @override
  List<Object> get props => [username];
}
