import 'dart:io';
import 'package:frontend/core/models/diagnosis_model.dart';
import 'package:frontend/features/diagnosis/data/datasources/diagnosis_remote_data_source.dart';
import 'package:frontend/features/diagnosis/domain/repositories/diagnosis_repository.dart';

class DiagnosisRepositoryImpl implements DiagnosisRepository {
  final DiagnosisRemoteDataSource remoteDataSource;
  DiagnosisRepositoryImpl(this.remoteDataSource);

  @override
  Future<DiagnosisResult> performDiagnosis(File imageFile) =>
      remoteDataSource.performDiagnosis(imageFile);

  @override
  Future<List<DiagnosisResult>> fetchHistory({int? limit}) =>
      remoteDataSource.fetchHistory(limit: limit);

  @override
  Future<bool> saveDiagnosis(DiagnosisResult result) =>
      remoteDataSource.saveDiagnosis(result);
}
