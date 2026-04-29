part of 'trades_bloc.dart';

abstract class TradesEvent extends Equatable {
  const TradesEvent();
  @override
  List<Object> get props => [];
}

class TradesLoaded extends TradesEvent {
  const TradesLoaded();
}

class TradesCancelRequested extends TradesEvent {
  /// DB id of the TradeOrder row (NOT ibkrOrderId).
  final int dbOrderId;
  const TradesCancelRequested(this.dbOrderId);
  @override
  List<Object> get props => [dbOrderId];
}
