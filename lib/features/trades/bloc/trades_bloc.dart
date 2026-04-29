import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/models.dart';
import '../../../services/api_service.dart';

part 'trades_event.dart';
part 'trades_state.dart';

class TradesBloc extends Bloc<TradesEvent, TradesState> {
  TradesBloc() : super(const TradesInitial()) {
    on<TradesLoaded>(_onLoad);
    on<TradesCancelRequested>(_onCancel);
  }

  Future<void> _onLoad(TradesLoaded event, Emitter<TradesState> emit) async {
    emit(const TradesLoading());
    try {
      final orders = await ApiService.instance.getOrders();
      emit(TradesSuccess(orders));
    } catch (e) {
      final s = e.toString();
      if (s.contains('UNAUTHORIZED')) {
        emit(const TradesFailure('Session expired', unauthorized: true));
      } else {
        emit(
            TradesFailure(s.contains('DioException') ? 'Connection error' : s));
      }
    }
  }

  Future<void> _onCancel(
      TradesCancelRequested event, Emitter<TradesState> emit) async {
    try {
      // Backend expects DB id (Long), not ibkrOrderId.
      await ApiService.instance.cancelOrder(event.dbOrderId);
      final orders = await ApiService.instance.getOrders();
      emit(TradesSuccess(orders));
    } catch (e) {
      final s = e.toString();
      emit(TradesFailure(
          s.contains('DioException') ? 'Connection error' : 'Cancel failed'));
    }
  }
}
