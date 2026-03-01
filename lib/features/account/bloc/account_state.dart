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
  final Account account;
  const AccountSuccess(this.account);
  @override
  List<Object?> get props => [account];
}

class AccountFailure extends AccountState {
  final String message;
  final bool unauthorized;
  const AccountFailure(this.message, {this.unauthorized = false});
  @override
  List<Object?> get props => [message];
}
