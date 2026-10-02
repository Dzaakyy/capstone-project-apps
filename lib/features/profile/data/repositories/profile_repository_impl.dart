import 'package:frontend/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:frontend/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<String, dynamic>> fetchProfile() => remoteDataSource.fetchProfile();

  @override
  Future<Map<String, dynamic>> updateProfile(String nama, String username, String? password) =>
      remoteDataSource.updateProfile(nama, username, password);

  @override
  Future<void> logout() => remoteDataSource.logout();
}
