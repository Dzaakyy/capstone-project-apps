import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mime/mime.dart' as mime;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final logger = Logger();

class DiagnosisResult {
  final String prediction;
  final double confidence;
  final String imagePath; 
  final String namaPenyakit;
  final String golongan;
  final String namaIlmiah;
  final String gejala;
  final String rekomendasiPerawatan;
  final int idPrediksi;
  final DateTime? tanggalDiagnosis;
  final String? error; 
  final String? message;

  DiagnosisResult({
    required this.prediction,
    required this.confidence,
    required this.imagePath,
    required this.namaPenyakit,
    required this.golongan,
    required this.namaIlmiah,
    required this.gejala,
    required this.rekomendasiPerawatan,
    required this.idPrediksi,
    this.tanggalDiagnosis,
    this.error,
    this.message
  });

  factory DiagnosisResult.fromJson(
      Map<String, dynamic> json, String imagePath) {
    return DiagnosisResult(
      prediction: json['prediksi']?['prediksi'] ?? 'Unknown',
      confidence: (json['prediksi']?['akurasi'] ?? 0.0).toDouble(),
      imagePath: json['prediksi']?['imageUrl'] ?? imagePath,
      namaPenyakit: json['penyakit']?['nama_penyakit'] ?? 'Unknown',
      golongan: json['penyakit']?['golongan'] ?? 'Unknown',
      namaIlmiah: json['penyakit']?['nama_ilmiah'] ?? 'Unknown',
      gejala: json['penyakit']?['gejala'] ?? 'Tidak ada informasi gejala',
      rekomendasiPerawatan:
          json['penyakit']?['rekomendasi_perawatan'] ?? 'Tidak ada rekomendasi',
      idPrediksi: json['prediksi']?['id_prediksi'] ?? 0,
      tanggalDiagnosis: json['tanggal_diagnosis'] != null
          ? DateTime.parse(json['tanggal_diagnosis'])
          : null,
          error: json['error'], 
      message: json['message'], 
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'confidence': confidence,
      'imagePath': imagePath,
      'namaPenyakit': namaPenyakit,
      'golongan': golongan,
      'namaIlmiah': namaIlmiah,
      'gejala': gejala,
      'rekomendasiPerawatan': rekomendasiPerawatan,
      'idPrediksi': idPrediksi,
      'tanggalDiagnosis': tanggalDiagnosis?.toIso8601String(),
      'error': error,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

class DiagnosisService {
  static const String _baseUrl = 'http://192.168.0.105:3000';

  static Future<DiagnosisResult> performDiagnosis(File imageFile) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      var mimeType = mime.lookupMimeType(imageFile.path) ?? 'image/jpeg';
      logger.i('Mengirim file: ${imageFile.path}, MIME Type: $mimeType');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/prediksi/create'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: mimeType != 'unknown' ? MediaType.parse(mimeType) : null,
      ));

      var response = await request.send();
      logger.i('Status Code: ${response.statusCode}');
      var responseData = await response.stream.bytesToString();
      logger.i('Response Data: $responseData');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseData);
        if (jsonResponse['error'] != null) {
          throw Exception(jsonResponse['error']);
        }
        return DiagnosisResult.fromJson(jsonResponse, imageFile.path);
      } else {
        throw Exception(
            'Failed to process prediction (Status: ${response.statusCode}) - $responseData');
      }
    } catch (e) {
      logger.e('Error: ${e.toString()}');
      throw Exception('Error during diagnosis: ${e.toString()}');
    }
  }

  static Future<bool> saveDiagnosis(DiagnosisResult diagnosisResult) async {
    try {
      logger.i('Saving diagnosis result:');
      logger.i('Prediction: ${diagnosisResult.prediction}');
      logger.i('Confidence: ${diagnosisResult.confidence}');
      logger.i('Image Path: ${diagnosisResult.imagePath}');
      logger.i('Timestamp: ${DateTime.now()}');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> diagnoses = prefs.getStringList('diagnoses') ?? [];
      diagnoses.add(jsonEncode(diagnosisResult.toJson()));
      await prefs.setStringList('diagnoses', diagnoses);

      return true;
    } catch (e) {
      logger.e('Error saving diagnosis: ${e.toString()}');
      return false;
    }
  }

 static Future<List<DiagnosisResult>> fetchUserHistory({int? limit}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      // Bangun URL dengan parameter limit jika ada
      String url = '$_baseUrl/api/history';
      if (limit != null) {
        url += '?limit=$limit';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      logger.i('History Status Code: ${response.statusCode}');
      logger.i('History Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((item) {
          final imagePath = item['prediksi']?['imageUrl'] ?? '';
          logger.i('Processing history item: ${item['id_diagnosis']}');
          return DiagnosisResult.fromJson(item, imagePath);
        }).toList();
      } else if (response.statusCode == 404) {
        return []; 
      } else {
        throw Exception(
            'Failed to fetch history (Status: ${response.statusCode}) - ${response.body}');
      }
    } catch (e) {
      logger.e('Error fetching history: ${e.toString()}');
      throw Exception('Error fetching history: ${e.toString()}');
    }
  }
}
