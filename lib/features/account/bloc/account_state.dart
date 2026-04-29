part of 'account_bloc.dart';

abstract class AccountState extends Equatable {
  const AccountState();
  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {
  const AccountInitial();
}

class AccountLoading extends AccountState {
  const AccountLoading();
}

class AccountSuccess extends AccountState {
  final ConnectionStatus status;
  const AccountSuccess(this.status);
  @override
  List<Object?> get props => [status];
}

class AccountFailure extends AccountState {
  final String message;
  final bool unauthorized;
  const AccountFailure(this.message, {this.unauthorized = false});
  @override
  List<Object?> get props => [message, unauthorized];
}
