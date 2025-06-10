// diagnosis_core.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

// DiagnosisResult Model
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

  // Convert DiagnosisResult to JSON for saving
  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'confidence': confidence,
      'imagePath': imagePath,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

// DiagnosisService
class DiagnosisService {
  static const String _baseUrl = 'http://10.0.2.2:3000';

  // Perform diagnosis prediction
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
        
        // Directly map backend response to DiagnosisResult
        return DiagnosisResult.fromJson(jsonResponse, imageFile.path);
      } else {
        throw Exception('Failed to process prediction (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error during diagnosis: ${e.toString()}');
    }
  }

  // Save diagnosis result
  static Future<bool> saveDiagnosis(DiagnosisResult diagnosisResult) async {
    try {
      // Here you can implement your preferred saving method:
      // 1. Save to local database (SQLite)
      // 2. Save to shared preferences
      // 3. Send to backend for saving
      // 4. Save to local file
      
      // For now, I'll implement a simple local storage simulation
      // You can replace this with your actual saving logic
      
      print('Saving diagnosis result:');
      print('Prediction: ${diagnosisResult.prediction}');
      print('Confidence: ${diagnosisResult.confidence}');
      print('Image Path: ${diagnosisResult.imagePath}');
      print('Timestamp: ${DateTime.now()}');
      
      // Simulate saving delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Return true if saving is successful
      return true;
    } catch (e) {
      print('Error saving diagnosis: ${e.toString()}');
      return false;
    }
  }

  // Optional: Save to backend if you want to store diagnosis history on server
  static Future<bool> saveDiagnosisToBackend(DiagnosisResult diagnosisResult) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/diagnosis/save'), // Adjust endpoint as needed
      );
      
      // Add diagnosis data
      request.fields['prediction'] = diagnosisResult.prediction;
      request.fields['confidence'] = diagnosisResult.confidence.toString();
      request.fields['timestamp'] = DateTime.now().toIso8601String();
      
      // Add image file if needed
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

