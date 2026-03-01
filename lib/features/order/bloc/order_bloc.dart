import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/models.dart';
import '../../../services/api_service.dart';

part 'order_event.dart';
part 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final ApiService _api;

  OrderBloc({ApiService? apiService})
      : _api = apiService ?? ApiService.instance,
        super(const OrderInitial()) {
    on<OrderSubmitted>(_onSubmitted);
    on<OrderReset>(_onReset);
  }

  Future<void> _onSubmitted(OrderSubmitted event, Emitter<OrderState> emit) async {
    emit(const OrderLoading());
    try {
      final result = await _api.sendOrder(OrderRequest(
        symbol: event.symbol,
        entryPrice: event.entryPrice,
        stopLoss: event.stopLoss,
      ));
      emit(OrderSuccess(result));
    } catch (e) {
      final msg = e.toString().contains('DioException')
          ? 'Connection error - check server'
          : e.toString().length > 80 ? '${e.toString().substring(0, 80)}...' : e.toString();
      emit(OrderFailure(msg));
    }
  }

  void _onReset(OrderReset event, Emitter<OrderState> emit) => emit(const OrderInitial());
}
