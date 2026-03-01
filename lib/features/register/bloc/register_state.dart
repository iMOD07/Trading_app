part of 'register_bloc.dart';
abstract class RegisterState extends Equatable {
  const RegisterState();
  @override List<Object?> get props => [];
}
class RegisterInitial extends RegisterState { const RegisterInitial(); }
class RegisterLoading extends RegisterState { const RegisterLoading(); }
class RegisterSuccess extends RegisterState { const RegisterSuccess(); }
class RegisterFailure extends RegisterState {
  final String message;
  const RegisterFailure(this.message);
  @override List<Object?> get props => [message];
}
