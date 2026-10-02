import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/constants/api_constants.dart';

abstract class AuthRemoteDataSource {
  Future<void> login(String username, String password);
  Future<void> register(String nama, String username, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<void> login(String username, String password) async {
    String urlLogin = "${ApiConstants.baseUrl}/api/user/login";
    
    var response = await http.post(
      Uri.parse(urlLogin),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    var dataLogin = jsonDecode(response.body);
    if (response.statusCode == 200 && dataLogin['msg'] == 'Login Berhasil') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      final rawCookie = response.headers['set-cookie'];
      String token = '';
      if (rawCookie != null) {
        int index = rawCookie.indexOf('accessToken=');
        if (index != -1) {
          token = rawCookie.substring(index + 'accessToken='.length).split(';')[0];
        }
      }
      await prefs.setString('accessToken', token);

      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
        );
        
        final String roleName = payload['roleName'] ?? '';
        
        if (roleName.toLowerCase() != 'petani') { 
          throw Exception("Akses ditolak. Halaman ini khusus untuk petani.");
        }

        await prefs.setInt('idUser', payload['userId']);
        await prefs.setString('namaUser', payload['username']);
        await prefs.setString('roleName', roleName);
      } else {
        throw Exception('Format token tidak valid');
      }
    } else {
      throw Exception(dataLogin['msg'] ?? 'Login Gagal');
    }
  }

  @override
  Future<void> register(String nama, String username, String password) async {
    String urlRegister = "${ApiConstants.baseUrl}/api/user/register";
    
    var response = await http.post(
      Uri.parse(urlRegister),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "nama": nama,
        "username": username,
        "password": password,
        "role_id": 2
      }),
    );

    var dataRegister = jsonDecode(response.body);
    if (response.statusCode != 201) {
       throw Exception(dataRegister['msg'] ?? 'Registrasi Gagal');
    }
  }
}
