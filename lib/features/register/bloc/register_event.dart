part of 'register_bloc.dart';
abstract class RegisterEvent extends Equatable {
  const RegisterEvent();
  @override List<Object> get props => [];
}
class RegisterSubmitted extends RegisterEvent {
  final String username, password, apiKey, apiSecret;
  const RegisterSubmitted({required this.username, required this.password, required this.apiKey, required this.apiSecret});
  @override List<Object> get props => [username, password, apiKey, apiSecret];
}
