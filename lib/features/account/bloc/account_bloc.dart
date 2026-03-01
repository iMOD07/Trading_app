import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/models.dart';
import '../../../services/api_service.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(const AccountInitial()) {
    on<AccountLoaded>(_onLoad);
  }

  Future<void> _onLoad(AccountLoaded event, Emitter<AccountState> emit) async {
    emit(const AccountLoading());
    try {
      final account = await ApiService.instance.getAccount();
      emit(AccountSuccess(account));
    } catch (e) {
      final s = e.toString();
      if (s.contains('UNAUTHORIZED')) {
        emit(const AccountFailure('Session expired', unauthorized: true));
      } else {
        emit(AccountFailure(
            s.contains('DioException') ? 'Connection error' : s));
      }
    }
  }
}
