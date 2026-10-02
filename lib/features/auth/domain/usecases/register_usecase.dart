import 'package:frontend/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<void> execute(String nama, String username, String password) async {
    return await repository.register(nama, username, password);
  }
}
