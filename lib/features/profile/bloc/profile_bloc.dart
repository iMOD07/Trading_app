import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/models.dart';
import '../../../services/api_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileUpdateSubmitted>(_onUpdateSubmitted);
  }

  Future<void> _onUpdateSubmitted(
      ProfileUpdateSubmitted event, Emitter<ProfileState> emit) async {
    emit(const ProfileLoading());
    try {
      await ApiService.instance.updateProfile(
        RegisterRequest(
          username: event.username,
          password: event.password ?? '',
          alpacaApiKey: event.alpacaApiKey ?? '',
          alpacaApiSecret: event.alpacaApiSecret ?? '',
          alpacaBaseUrl:
              event.alpacaBaseUrl ?? 'https://paper-api.alpaca.markets',
        ),
      );
      emit(const ProfileSuccess('Profile updated successfully'));
    } on DioException catch (e) {
      final data = e.response?.data;
      final serverMsg = data is Map ? data['error'] as String? : null;
      emit(ProfileFailure(serverMsg ?? 'Update failed'));
    } on Exception catch (e) {
      emit(ProfileFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
