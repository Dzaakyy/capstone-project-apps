import 'package:equatable/equatable.dart';
import 'package:frontend/core/models/diagnosis_model.dart';

abstract class DiagnosisState extends Equatable {
  const DiagnosisState();
  @override
  List<Object?> get props => [];
}

class DiagnosisInitial extends DiagnosisState {}

class DiagnosisLoading extends DiagnosisState {}

class DiagnosisSuccess extends DiagnosisState {
  final DiagnosisResult result;
  const DiagnosisSuccess(this.result);
  @override
  List<Object?> get props => [result];
}

class DiagnosisError extends DiagnosisState {
  final String message;
  const DiagnosisError(this.message);
  @override
  List<Object?> get props => [message];
}

class HistoryLoading extends DiagnosisState {}

class HistoryLoaded extends DiagnosisState {
  final List<DiagnosisResult> histories;
  const HistoryLoaded(this.histories);
  @override
  List<Object?> get props => [histories];
}

class HistoryError extends DiagnosisState {
  final String message;
  const HistoryError(this.message);
  @override
  List<Object?> get props => [message];
}

class DiagnosisSaving extends DiagnosisState {}

class DiagnosisSaveSuccess extends DiagnosisState {}

class DiagnosisSaveError extends DiagnosisState {
  final String message;
  const DiagnosisSaveError(this.message);
  @override
  List<Object?> get props => [message];
}
