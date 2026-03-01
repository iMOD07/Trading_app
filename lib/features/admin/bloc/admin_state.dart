part of 'admin_bloc.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  @override List<Object?> get props => [];
}

class AdminInitial  extends AdminState { const AdminInitial(); }
class AdminLoading  extends AdminState { const AdminLoading(); }
class AdminSuccess  extends AdminState {
  final List<AppUser> users;
  const AdminSuccess(this.users);
  @override List<Object?> get props => [users];
}
class AdminFailure  extends AdminState {
  final String message;
  const AdminFailure(this.message);
  @override List<Object?> get props => [message];
}
