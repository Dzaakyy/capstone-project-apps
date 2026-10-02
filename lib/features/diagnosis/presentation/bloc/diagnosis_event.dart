import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/models/diagnosis_model.dart';

abstract class DiagnosisEvent extends Equatable {
  const DiagnosisEvent();
  @override
  List<Object?> get props => [];
}

class DiagnosisRequested extends DiagnosisEvent {
  final File imageFile;
  const DiagnosisRequested(this.imageFile);
  @override
  List<Object?> get props => [imageFile];
}

class HistoryFetchRequested extends DiagnosisEvent {
  final int? limit;
  const HistoryFetchRequested({this.limit});
  @override
  List<Object?> get props => [limit];
}

class DiagnosisSaveRequested extends DiagnosisEvent {
  final DiagnosisResult result;
  const DiagnosisSaveRequested(this.result);
  @override
  List<Object?> get props => [result];
}
