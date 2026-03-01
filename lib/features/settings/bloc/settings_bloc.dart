import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/models.dart';
import '../../../services/api_service.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsInitial()) {
    on<SettingsLoaded>(_onLoad);
    on<SettingsSaved>(_onSave);
  }

  Future<void> _onLoad(SettingsLoaded event, Emitter<SettingsState> emit) async {
    emit(const SettingsLoading());
    try {
      final s = await ApiService.instance.getSettings();
      emit(SettingsDataLoaded(s));
    } catch (e) {
      emit(SettingsFailure(e.toString().contains('DioException') ? 'Connection error' : e.toString()));
    }
  }

  Future<void> _onSave(SettingsSaved event, Emitter<SettingsState> emit) async {
    emit(const SettingsLoading());
    try {
      await ApiService.instance.saveSettings(event.settings);
      emit(const SettingsSaveSuccess());
      await Future.delayed(const Duration(seconds: 1));
      emit(SettingsDataLoaded(event.settings));
    } catch (e) {
      emit(SettingsFailure(e.toString().contains('DioException') ? 'Connection error' : e.toString()));
    }
  }
}
