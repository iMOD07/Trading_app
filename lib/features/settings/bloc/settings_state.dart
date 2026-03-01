part of 'settings_bloc.dart';
abstract class SettingsState extends Equatable {
  const SettingsState();
  @override List<Object?> get props => [];
}
class SettingsInitial extends SettingsState { const SettingsInitial(); }
class SettingsLoading extends SettingsState { const SettingsLoading(); }
class SettingsDataLoaded extends SettingsState {
  final AppSettings settings;
  const SettingsDataLoaded(this.settings);
  @override List<Object?> get props => [settings];
}
class SettingsSaveSuccess extends SettingsState { const SettingsSaveSuccess(); }
class SettingsFailure extends SettingsState {
  final String message;
  const SettingsFailure(this.message);
  @override List<Object?> get props => [message];
}
