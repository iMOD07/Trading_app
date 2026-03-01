part of 'order_bloc.dart';
abstract class OrderState extends Equatable {
  const OrderState();
  @override List<Object?> get props => [];
}
class OrderInitial extends OrderState { const OrderInitial(); }
class OrderLoading extends OrderState { const OrderLoading(); }
class OrderSuccess extends OrderState {
  final Map<String, dynamic> result;
  const OrderSuccess(this.result);
  @override List<Object?> get props => [result];
}
class OrderFailure extends OrderState {
  final String message;
  const OrderFailure(this.message);
  @override List<Object?> get props => [message];
}
