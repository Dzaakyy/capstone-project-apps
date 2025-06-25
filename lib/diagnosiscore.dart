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
  final String gejala;
  final String rekomendasiPerawatan;
  final int idPrediksi;

  DiagnosisResult({
    required this.prediction,
    required this.confidence,
    required this.imagePath,
    required this.namaPenyakit,
    required this.gejala,
    required this.rekomendasiPerawatan,
    required this.idPrediksi,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json, String imagePath) {
    return DiagnosisResult(
      prediction: json['prediction']?.toString() ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      imagePath: imagePath,
      namaPenyakit: json['penyakit']?['nama_penyakit'] ?? 'Unknown',
      gejala: json['penyakit']?['gejala'] ?? 'Tidak ada informasi gejala',
      rekomendasiPerawatan:
          json['penyakit']?['rekomendasi_perawatan'] ?? 'Tidak ada rekomendasi',
      idPrediksi: json['prediksi']?['id_prediksi'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'confidence': confidence,
      'imagePath': imagePath,
      'namaPenyakit': namaPenyakit,
      'gejala': gejala,
      'rekomendasiPerawatan': rekomendasiPerawatan,
      'idPrediksi': idPrediksi,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

class DiagnosisService {
  static const String _baseUrl = 'http://10.0.2.2:3000';

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

      await Future.delayed(const Duration(milliseconds: 500));

      return true;
    } catch (e) {
      logger.e('Error saving diagnosis: ${e.toString()}');
      return false;
    }
  }

  static Future<bool> saveDiagnosisToBackend(DiagnosisResult diagnosisResult) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan. Silakan login kembali.');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/diagnosis/save'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['prediction'] = diagnosisResult.prediction;
      request.fields['confidence'] = diagnosisResult.confidence.toString();
      request.fields['id_prediksi'] = diagnosisResult.idPrediksi.toString();
      request.fields['timestamp'] = DateTime.now().toIso8601String();

      if (diagnosisResult.imagePath.isNotEmpty) {
        var mimeType = mime.lookupMimeType(diagnosisResult.imagePath) ?? 'image/jpeg';
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          diagnosisResult.imagePath,
          contentType: mimeType != 'unknown' ? MediaType.parse(mimeType) : null,
        ));
      }

      var response = await request.send();
      logger.i('Save Diagnosis Status Code: ${response.statusCode}');
      var responseData = await response.stream.bytesToString();
      logger.i('Save Diagnosis Response: $responseData');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Failed to save diagnosis (Status: ${response.statusCode}) - $responseData');
      }
    } catch (e) {
      logger.e('Error saving diagnosis to backend: ${e.toString()}');
      return false;
    }
  }
}