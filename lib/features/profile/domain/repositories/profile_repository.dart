abstract class ProfileRepository {
  Future<Map<String, dynamic>> fetchProfile();
  Future<Map<String, dynamic>> updateProfile(String nama, String username, String? password);
  Future<void> logout();
}
