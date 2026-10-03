import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/constants/api_constants.dart';

abstract class ProfileRemoteDataSource {
  Future<Map<String, dynamic>> fetchProfile();
  Future<Map<String, dynamic>> updateProfile(String nama, String username, String? password);
  Future<void> logout();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }
    return token;
  }

  @override
  Future<Map<String, dynamic>> fetchProfile() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal memuat profil');
  }

  @override
  Future<Map<String, dynamic>> updateProfile(String nama, String username, String? password) async {
    final token = await _getToken();
    final body = {
      'nama': nama,
      'username': username,
      if (password != null && password.isNotEmpty) 'password': password,
    };
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/api/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Gagal memperbarui profil';
      throw Exception(error);
    }
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('role');
  }
}
