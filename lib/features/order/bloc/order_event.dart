part of 'order_bloc.dart';
abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override List<Object> get props => [];
}
class OrderSubmitted extends OrderEvent {
  final String symbol;
  final double entryPrice;
  final double stopLoss;
  const OrderSubmitted({required this.symbol, required this.entryPrice, required this.stopLoss});
  @override List<Object> get props => [symbol, entryPrice, stopLoss];
}
class OrderReset extends OrderEvent { const OrderReset(); }
