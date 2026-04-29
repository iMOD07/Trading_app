part of 'trades_bloc.dart';

abstract class TradesState extends Equatable {
  const TradesState();
  @override
  List<Object?> get props => [];
}

class TradesInitial extends TradesState {
  const TradesInitial();
}

class TradesLoading extends TradesState {
  const TradesLoading();
}

class TradesSuccess extends TradesState {
  final List<TradeOrder> orders;
  const TradesSuccess(this.orders);
  @override
  List<Object?> get props => [orders];
}

class TradesFailure extends TradesState {
  final String message;
  final bool unauthorized;
  const TradesFailure(this.message, {this.unauthorized = false});
  @override
  List<Object?> get props => [message, unauthorized];
}
