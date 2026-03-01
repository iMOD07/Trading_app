import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/models.dart';
import '../../../services/api_service.dart';

part 'trades_event.dart';
part 'trades_state.dart';

class TradesBloc extends Bloc<TradesEvent, TradesState> {
  TradesBloc() : super(const TradesInitial()) {
    on<TradesLoaded>(_onLoad);
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
        emit(TradesFailure(s.contains('DioException') ? 'Connection error' : s));
      }
    }
  }
}
