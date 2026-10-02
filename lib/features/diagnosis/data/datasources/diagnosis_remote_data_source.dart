import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart' as mime;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/core/constants/api_constants.dart';
import 'package:frontend/core/models/diagnosis_model.dart';

final _logger = Logger();

abstract class DiagnosisRemoteDataSource {
  Future<DiagnosisResult> performDiagnosis(File imageFile);
  Future<List<DiagnosisResult>> fetchHistory({int? limit});
  Future<bool> saveDiagnosis(DiagnosisResult result);
}

class DiagnosisRemoteDataSourceImpl implements DiagnosisRemoteDataSource {
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login kembali.');
    }
    return token;
  }

  @override
  Future<DiagnosisResult> performDiagnosis(File imageFile) async {
    final token = await _getToken();
    var mimeType = mime.lookupMimeType(imageFile.path) ?? 'image/jpeg';
    _logger.i('Mengirim file: ${imageFile.path}, MIME: $mimeType');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/prediksi/create'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      contentType: mimeType != 'unknown' ? MediaType.parse(mimeType) : null,
    ));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    _logger.i('Status: ${response.statusCode}, Body: $responseData');

    if (response.statusCode == 200) {
      var json = jsonDecode(responseData);
      if (json['error'] != null) throw Exception(json['error']);
      return DiagnosisResult.fromJson(json, imageFile.path);
    } else {
      throw Exception(
          'Gagal memproses prediksi (Status: ${response.statusCode})');
    }
  }

  @override
  Future<List<DiagnosisResult>> fetchHistory({int? limit}) async {
    final token = await _getToken();
    String url = '${ApiConstants.baseUrl}/api/history';
    if (limit != null) url += '?limit=$limit';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((item) {
        final imagePath = item['prediksi']?['imageUrl'] ?? '';
        return DiagnosisResult.fromJson(item, imagePath);
      }).toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception(
          'Gagal mengambil riwayat (Status: ${response.statusCode})');
    }
  }

  @override
  Future<bool> saveDiagnosis(DiagnosisResult result) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/api/history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'id_prediksi': result.idPrediksi}),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
