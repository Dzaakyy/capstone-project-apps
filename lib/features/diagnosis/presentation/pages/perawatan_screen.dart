import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/models/diagnosis_model.dart';
import 'package:camera/camera.dart';
import 'package:frontend/features/home/presentation/pages/home_screen.dart';
import 'package:frontend/features/diagnosis/presentation/pages/diagnosis_screen.dart';
import 'package:frontend/features/diagnosis/presentation/bloc/diagnosis_bloc.dart';
import 'package:frontend/features/diagnosis/presentation/bloc/diagnosis_event.dart';
import 'package:frontend/features/diagnosis/presentation/bloc/diagnosis_state.dart';
import 'package:frontend/core/utils/snackbar_util.dart';

class RekomendasiPerawatanPage extends StatelessWidget {
  final DiagnosisResult diagnosisResult;
  final List<CameraDescription> cameras;
  final String recommendationText;
  final bool fromHistory;

  const RekomendasiPerawatanPage({
    super.key,
    required this.diagnosisResult,
    required this.cameras,
    this.recommendationText = '',
    this.fromHistory = false,
  });

  String get _defaultRecommendation {
    return diagnosisResult.rekomendasiPerawatan.isNotEmpty
        ? diagnosisResult.rekomendasiPerawatan
        : 'Tidak ada rekomendasi perawatan tersedia.';
  }

  @override
  Widget build(BuildContext context) {
    final recommendation =
        recommendationText.isNotEmpty ? recommendationText : _defaultRecommendation;
    final hasImage = diagnosisResult.imagePath.isNotEmpty;
    final isNetwork = hasImage && diagnosisResult.imagePath.startsWith('http');

    return BlocConsumer<DiagnosisBloc, DiagnosisState>(
      listener: (context, state) {
        if (state is DiagnosisSaveSuccess) {
          SnackbarUtil.showSuccess(context, 'Diagnosis berhasil disimpan');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(cameras: cameras),
            ),
            (route) => false,
          );
        } else if (state is DiagnosisSaveError) {
          SnackbarUtil.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isSaving = state is DiagnosisSaving;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          body: Stack(
            children: [
              // Hero Image
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.45,
                child: hasImage
                    ? (isNetwork
                        ? Image.network(
                            diagnosisResult.imagePath,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(diagnosisResult.imagePath),
                            fit: BoxFit.cover,
                          ))
                    : Container(
                        color: Colors.green.shade800,
                        child: const Center(
                          child: Icon(Icons.eco, size: 80, color: Colors.white54),
                        ),
                      ),
              ),

              // Overlay Gradient
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.45,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // App Bar
              Positioned(
                top: 50,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (fromHistory)
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        ),
                      )
                    else
                      const SizedBox(width: 40),
                    const Text(
                      'Treatment Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Draggable/Overlapping Content
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.65,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Reference back to Diagnosis
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DiagnosisPage(
                                        diagnosisResult: diagnosisResult,
                                        cameras: cameras,
                                        showBackButton: true,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.blue.withOpacity(0.1)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.analytics_rounded, color: Colors.blue.shade700),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Diagnosed as',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.blue.shade800,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              diagnosisResult.namaPenyakit,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1A1F2C),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.blue.shade700),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Recommendation Section
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.medical_services_rounded, size: 20, color: Colors.green.shade600),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Recommended Action',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1F2C),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F9FC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Text(
                                  recommendation,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade700,
                                    height: 1.7,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                              
                              const SizedBox(height: 40),
                              
                              if (!fromHistory)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isSaving
                                        ? null
                                        : () => context
                                            .read<DiagnosisBloc>()
                                            .add(DiagnosisSaveRequested(diagnosisResult)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F172A),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: isSaving
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Save to History',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
