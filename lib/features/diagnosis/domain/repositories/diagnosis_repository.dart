import 'dart:io';
import 'package:frontend/core/models/diagnosis_model.dart';

abstract class DiagnosisRepository {
  Future<DiagnosisResult> performDiagnosis(File imageFile);
  Future<List<DiagnosisResult>> fetchHistory({int? limit});
  Future<bool> saveDiagnosis(DiagnosisResult result);
}
