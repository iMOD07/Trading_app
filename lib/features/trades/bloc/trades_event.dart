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
  final String ibkrOrderId;
  const TradesCancelRequested(this.ibkrOrderId);
  @override
  List<Object> get props => [ibkrOrderId];
}
