import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/models.dart';
import '../../../services/api_service.dart';
import '../../../services/auth_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginInitial()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(const LoginLoading());
    try {
      final res = await ApiService.instance.login(
        LoginRequest(username: event.username, password: event.password),
      );
      final token = res['token'] as String?;
      final username = res['username'] as String? ?? event.username;
      final role = res['role'] as String? ?? 'USER';
      if (token == null || token.isEmpty) throw Exception('No token received');
      await AuthService.saveToken(token, username, role: role);
      emit(const LoginSuccess());
    } on Exception catch (e) {
      final msg = e.toString().contains('DioException')
          ? 'Invalid username or password'
          : e.toString().replaceAll('Exception: ', '');
      emit(LoginFailure(msg));
      await Future.delayed(const Duration(seconds: 3));
      if (!isClosed) emit(const LoginInitial());
    }
  }
}
