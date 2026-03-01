part of 'settings_bloc.dart';
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override List<Object> get props => [];
}
class SettingsLoaded extends SettingsEvent { const SettingsLoaded(); }
class SettingsSaved extends SettingsEvent {
  final AppSettings settings;
  const SettingsSaved(this.settings);
  @override List<Object> get props => [settings];
}
