import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/models.dart';
import '../../../services/api_service.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(const RegisterInitial()) {
    on<RegisterSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(RegisterSubmitted event, Emitter<RegisterState> emit) async {
    emit(const RegisterLoading());
    try {
      await ApiService.instance.register(RegisterRequest(
        username: event.username,
        password: event.password,
        alpacaApiKey: event.apiKey,
        alpacaApiSecret: event.apiSecret,
      ));
      emit(const RegisterSuccess());
    } catch (e) {
      final msg = e.toString().contains('DioException')
          ? 'Registration failed - check your details'
          : e.toString().replaceAll('Exception: ', '');
      emit(RegisterFailure(msg));
      await Future.delayed(const Duration(seconds: 3));
      if (!isClosed) emit(const RegisterInitial());
    }
  }
}
