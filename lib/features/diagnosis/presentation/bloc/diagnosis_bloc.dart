import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/diagnosis/domain/usecases/diagnosis_usecases.dart';
import 'diagnosis_event.dart';
import 'diagnosis_state.dart';

class DiagnosisBloc extends Bloc<DiagnosisEvent, DiagnosisState> {
  final PerformDiagnosisUseCase performDiagnosisUseCase;
  final FetchHistoryUseCase fetchHistoryUseCase;
  final SaveDiagnosisUseCase saveDiagnosisUseCase;

  DiagnosisBloc({
    required this.performDiagnosisUseCase,
    required this.fetchHistoryUseCase,
    required this.saveDiagnosisUseCase,
  }) : super(DiagnosisInitial()) {
    on<DiagnosisRequested>(_onDiagnosisRequested);
    on<HistoryFetchRequested>(_onHistoryFetchRequested);
    on<DiagnosisSaveRequested>(_onDiagnosisSaveRequested);
  }

  Future<void> _onDiagnosisRequested(
    DiagnosisRequested event,
    Emitter<DiagnosisState> emit,
  ) async {
    emit(DiagnosisLoading());
    try {
      final result = await performDiagnosisUseCase.execute(event.imageFile);
      emit(DiagnosisSuccess(result));
    } catch (e) {
      emit(DiagnosisError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onHistoryFetchRequested(
    HistoryFetchRequested event,
    Emitter<DiagnosisState> emit,
  ) async {
    emit(HistoryLoading());
    try {
      final histories = await fetchHistoryUseCase.execute(limit: event.limit);
      emit(HistoryLoaded(histories));
    } catch (e) {
      emit(HistoryError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDiagnosisSaveRequested(
    DiagnosisSaveRequested event,
    Emitter<DiagnosisState> emit,
  ) async {
    emit(DiagnosisSaving());
    try {
      final success = await saveDiagnosisUseCase.execute(event.result);
      if (success) {
        emit(DiagnosisSaveSuccess());
      } else {
        emit(const DiagnosisSaveError('Gagal menyimpan diagnosis.'));
      }
    } catch (e) {
      emit(DiagnosisSaveError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
