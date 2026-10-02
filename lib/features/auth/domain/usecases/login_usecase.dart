import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<void> execute(String username, String password) async {
    return await repository.login(username, password);
  }
}
