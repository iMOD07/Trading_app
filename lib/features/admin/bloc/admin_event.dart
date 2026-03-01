part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();
  @override List<Object> get props => [];
}

class AdminUsersLoaded extends AdminEvent { const AdminUsersLoaded(); }

class AdminUserActivated extends AdminEvent {
  final int id;
  const AdminUserActivated(this.id);
  @override List<Object> get props => [id];
}

class AdminUserDeactivated extends AdminEvent {
  final int id;
  const AdminUserDeactivated(this.id);
  @override List<Object> get props => [id];
}

class AdminRoleChanged extends AdminEvent {
  final int id;
  final String role;
  const AdminRoleChanged(this.id, this.role);
  @override List<Object> get props => [id, role];
}
