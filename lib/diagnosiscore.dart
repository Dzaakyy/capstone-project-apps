import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DiagnosisResult {
  final String prediction;
  final double confidence;
  final String imagePath;

  DiagnosisResult({
    required this.prediction,
    required this.confidence,
    required this.imagePath,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json, String imagePath) {
    return DiagnosisResult(
      prediction: json['prediction']?.toString() ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      imagePath: imagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'confidence': confidence,
      'imagePath': imagePath,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

class DiagnosisService {
  static const String _baseUrl = 'http://10.0.2.2:3000';

  static Future<DiagnosisResult> performDiagnosis(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/prediksi/create'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path)
      );
      
      var response = await request.send();
      
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        
        if (jsonResponse['error'] != null) {
          throw Exception(jsonResponse['error']);
        }
        
        return DiagnosisResult.fromJson(jsonResponse, imageFile.path);
      } else {
        throw Exception('Failed to process prediction (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error during diagnosis: ${e.toString()}');
    }
  }

  static Future<bool> saveDiagnosis(DiagnosisResult diagnosisResult) async {
    try {
      
      print('Saving diagnosis result:');
      print('Prediction: ${diagnosisResult.prediction}');
      print('Confidence: ${diagnosisResult.confidence}');
      print('Image Path: ${diagnosisResult.imagePath}');
      print('Timestamp: ${DateTime.now()}');
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      return true;
    } catch (e) {
      print('Error saving diagnosis: ${e.toString()}');
      return false;
    }
  }

  static Future<bool> saveDiagnosisToBackend(DiagnosisResult diagnosisResult) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/diagnosis/save'), 
      );
      
      request.fields['prediction'] = diagnosisResult.prediction;
      request.fields['confidence'] = diagnosisResult.confidence.toString();
      request.fields['timestamp'] = DateTime.now().toIso8601String();
      
      if (diagnosisResult.imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('image', diagnosisResult.imagePath)
        );
      }
      
      var response = await request.send();
      
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to save diagnosis (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error saving diagnosis to backend: ${e.toString()}');
      return false;
    }
  }
}

