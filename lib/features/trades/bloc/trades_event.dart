part of 'trades_bloc.dart';
abstract class TradesEvent extends Equatable {
  const TradesEvent();
  @override List<Object> get props => [];
}
class TradesLoaded extends TradesEvent { const TradesLoaded(); }
class TradesCancelRequested extends TradesEvent {
  final String alpacaOrderId;
  const TradesCancelRequested(this.alpacaOrderId);
  @override List<Object> get props => [alpacaOrderId];
}
