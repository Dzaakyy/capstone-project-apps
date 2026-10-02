abstract class AuthRepository {
  Future<void> login(String username, String password);
  Future<void> register(String nama, String username, String password);
}
