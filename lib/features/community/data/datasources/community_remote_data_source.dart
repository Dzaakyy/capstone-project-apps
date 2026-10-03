import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart' as mime;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/models/komunitas_model.dart';
import 'package:frontend/core/models/komentar_model.dart';

abstract class CommunityRemoteDataSource {
  Future<List<Komunitas>> getAllPosts();
  Future<List<Komunitas>> searchPosts(String query);
  Future<List<Komunitas>> getUserPosts();
  Future<void> createPost(String judul, String isi, File? image);
  Future<void> updatePost(int postId, String judul, String isi, File? image);
  Future<void> deletePost(int postId);
  Future<List<Komentar>> getComments(int postId);
  Future<void> addComment(int postId, String isi);
  Future<void> updateComment(int komentarId, String isi);
  Future<void> deleteComment(int komentarId);
}

class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }
    return token;
  }

  @override
  Future<List<Komunitas>> getAllPosts() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/komunitas'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => Komunitas.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat postingan (Status: ${response.statusCode})');
  }

  @override
  Future<List<Komunitas>> searchPosts(String query) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/komunitas/cari?query=$query'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => Komunitas.fromJson(e)).toList();
    }
    throw Exception('Gagal mencari postingan');
  }

  @override
  Future<List<Komunitas>> getUserPosts() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/postingan/user'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((e) => Komunitas.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat postingan Anda');
  }

  @override
  Future<void> deletePost(int postId) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/api/komunitas/$postId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus postingan');
    }
  }

  @override
  Future<List<Komentar>> getComments(int postId) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/api/komunitas/$postId/komentar'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body);
      final List<dynamic> komentarData = json['komentar'] ?? [];
      return komentarData.map((e) => Komentar.fromJson(e)).toList();
    }
    return [];
  }

  @override
  Future<void> addComment(int postId, String isi) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/komunitas/$postId/komentar'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'isi_komentar': isi}),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Gagal mengirim komentar');
    }
  }

  @override
  Future<void> updateComment(int komentarId, String isi) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/api/komunitas/komentar/$komentarId'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'isi_komentar': isi}),
    );
    if (response.statusCode != 200) throw Exception('Gagal mengubah komentar');
  }

  @override
  Future<void> deleteComment(int komentarId) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/api/komunitas/komentar/$komentarId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) throw Exception('Gagal menghapus komentar');
  }

  @override
  Future<void> createPost(String judul, String isi, File? image) async {
    final token = await _getToken();
    var request = http.MultipartRequest(
        'POST', Uri.parse('${ApiConstants.baseUrl}/api/komunitas'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['judul'] = judul;
    request.fields['isi'] = isi;
    if (image != null) {
      var mimeType = mime.lookupMimeType(image.path) ?? 'image/jpeg';
      request.files.add(await http.MultipartFile.fromPath('image', image.path,
          contentType: MediaType.parse(mimeType)));
    }
    final streamedResponse = await request.send();
    if (streamedResponse.statusCode != 201) {
      throw Exception('Gagal membuat postingan');
    }
  }

  @override
  Future<void> updatePost(int postId, String judul, String isi, File? image) async {
    final token = await _getToken();
    var request = http.MultipartRequest(
        'PUT', Uri.parse('${ApiConstants.baseUrl}/api/komunitas/$postId'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['judul'] = judul;
    request.fields['isi'] = isi;
    if (image != null) {
      var mimeType = mime.lookupMimeType(image.path) ?? 'image/jpeg';
      request.files.add(await http.MultipartFile.fromPath('image', image.path,
          contentType: MediaType.parse(mimeType)));
    }
    final streamedResponse = await request.send();
    if (streamedResponse.statusCode != 200) {
      throw Exception('Gagal mengubah postingan');
    }
  }
}
