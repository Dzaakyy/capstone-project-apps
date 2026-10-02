import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/profile/domain/usecases/profile_usecases.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FetchProfileUseCase fetchProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final LogoutUseCase logoutUseCase;

  ProfileBloc({
    required this.fetchProfileUseCase,
    required this.updateProfileUseCase,
    required this.logoutUseCase,
  }) : super(ProfileInitial()) {
    on<ProfileFetchRequested>(_onFetchProfile);
    on<ProfileUpdateRequested>(_onUpdateProfile);
    on<ProfileLogoutRequested>(_onLogoutProfile);
  }

  Future<void> _onFetchProfile(ProfileFetchRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final data = await fetchProfileUseCase.execute();
      emit(ProfileLoaded(data));
    } catch (e) {
      emit(ProfileError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onUpdateProfile(ProfileUpdateRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final data = await updateProfileUseCase.execute(event.nama, event.username, event.password);
      emit(ProfileUpdateSuccess(data));
      emit(ProfileLoaded(data)); // Stay on loaded state with new data
    } catch (e) {
      emit(ProfileError(e.toString().replaceFirst('Exception: ', '')));
      // Fetch again to restore old data on error
      add(ProfileFetchRequested()); 
    }
  }

  Future<void> _onLogoutProfile(ProfileLogoutRequested event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await logoutUseCase.execute();
      emit(ProfileLogoutSuccess());
    } catch (e) {
      emit(ProfileError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
