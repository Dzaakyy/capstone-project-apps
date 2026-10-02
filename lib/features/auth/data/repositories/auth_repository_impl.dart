import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> login(String username, String password) async {
    return await remoteDataSource.login(username, password);
  }

  @override
  Future<void> register(String nama, String username, String password) async {
    return await remoteDataSource.register(nama, username, password);
  }
}
