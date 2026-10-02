import 'dart:io';
import 'package:frontend/core/models/diagnosis_model.dart';
import 'package:frontend/features/diagnosis/domain/repositories/diagnosis_repository.dart';

class PerformDiagnosisUseCase {
  final DiagnosisRepository repository;
  PerformDiagnosisUseCase(this.repository);

  Future<DiagnosisResult> execute(File imageFile) =>
      repository.performDiagnosis(imageFile);
}

class FetchHistoryUseCase {
  final DiagnosisRepository repository;
  FetchHistoryUseCase(this.repository);

  Future<List<DiagnosisResult>> execute({int? limit}) =>
      repository.fetchHistory(limit: limit);
}

class SaveDiagnosisUseCase {
  final DiagnosisRepository repository;
  SaveDiagnosisUseCase(this.repository);

  Future<bool> execute(DiagnosisResult result) =>
      repository.saveDiagnosis(result);
}
