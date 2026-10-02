import 'package:frontend/features/profile/domain/repositories/profile_repository.dart';

class FetchProfileUseCase {
  final ProfileRepository repository;
  FetchProfileUseCase(this.repository);
  Future<Map<String, dynamic>> execute() => repository.fetchProfile();
}

class UpdateProfileUseCase {
  final ProfileRepository repository;
  UpdateProfileUseCase(this.repository);
  Future<Map<String, dynamic>> execute(String nama, String username, String? password) =>
      repository.updateProfile(nama, username, password);
}

class LogoutUseCase {
  final ProfileRepository repository;
  LogoutUseCase(this.repository);
  Future<void> execute() => repository.logout();
}
