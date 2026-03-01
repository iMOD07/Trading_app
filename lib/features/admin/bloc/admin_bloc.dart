import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/models.dart';
import '../../../services/api_service.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  AdminBloc() : super(const AdminInitial()) {
    on<AdminUsersLoaded>(_onLoad);
    on<AdminUserActivated>(_onActivate);
    on<AdminUserDeactivated>(_onDeactivate);
    on<AdminRoleChanged>(_onRoleChange);
  }

  Future<void> _onLoad(AdminUsersLoaded e, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    try {
      final users = await ApiService.instance.getUsers();
      emit(AdminSuccess(users));
    } catch (e) {
      emit(AdminFailure(_err(e)));
    }
  }

  Future<void> _onActivate(
      AdminUserActivated e, Emitter<AdminState> emit) async {
    try {
      await ApiService.instance.activateUser(e.id);
      add(const AdminUsersLoaded());
    } catch (err) {
      emit(AdminFailure(_err(err)));
    }
  }

  Future<void> _onDeactivate(
      AdminUserDeactivated e, Emitter<AdminState> emit) async {
    try {
      await ApiService.instance.deactivateUser(e.id);
      add(const AdminUsersLoaded());
    } catch (err) {
      emit(AdminFailure(_err(err)));
    }
  }

  Future<void> _onRoleChange(
      AdminRoleChanged e, Emitter<AdminState> emit) async {
    try {
      await ApiService.instance.changeRole(e.id, e.role);
      add(const AdminUsersLoaded());
    } catch (err) {
      emit(AdminFailure(_err(err)));
    }
  }

  String _err(dynamic e) {
    final s = e.toString();
    if (s.contains('UNAUTHORIZED')) return 'Unauthorized';
    if (s.contains('DioException')) return 'Connection error';
    return s.length > 60 ? '${s.substring(0, 60)}...' : s;
  }
}
