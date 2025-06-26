import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/diagnosiscore.dart';
import 'package:camera/camera.dart';
import 'package:frontend/home.dart';
import 'package:frontend/diagnosispage.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class RekomendasiPerawatanPage extends StatefulWidget {
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

  @override
  State<RekomendasiPerawatanPage> createState() =>
      _RekomendasiPerawatanPageState();
}

class _RekomendasiPerawatanPageState extends State<RekomendasiPerawatanPage> {
  bool _isSaving = false;

  String get _currentDate {
    final now = DateTime.now();
    final months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    return '${now.day} ${months[now.month]}';
  }

  String get _defaultRecommendation {
    return widget.diagnosisResult.rekomendasiPerawatan.isNotEmpty
        ? widget.diagnosisResult.rekomendasiPerawatan
        : 'Tidak ada rekomendasi perawatan tersedia.';
  }

  Future<void> _saveDiagnosis() async {
    if (widget.fromHistory) {
      Navigator.pop(
          context); 
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      bool saveSuccess =
          await DiagnosisService.saveDiagnosis(widget.diagnosisResult);

      if (saveSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Diagnosis berhasil disimpan'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(cameras: widget.cameras),
          ),
          (route) => false,
        );
      } else if (mounted) {
        _showMessage('Gagal menyimpan diagnosis. Silakan coba lagi.',
            isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('Error: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (widget.fromHistory) return; 

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommendation = widget.recommendationText.isNotEmpty
        ? widget.recommendationText
        : _defaultRecommendation;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _currentDate,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        leading: widget.fromHistory
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Diagnosis Result Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      size: 20,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Hasil Diagnosis',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiagnosisPage(
                        diagnosisResult: widget.diagnosisResult,
                        cameras: widget.cameras,
                        showBackButton: true,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black87,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Image Preview
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: widget.diagnosisResult.imagePath.isNotEmpty
                              ? widget.diagnosisResult.imagePath
                                      .startsWith('http')
                                  ? Image.network(
                                      widget.diagnosisResult.imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.image,
                                          size: 30,
                                          color: Colors.grey.shade500,
                                        );
                                      },
                                    )
                                  : Image.file(
                                      File(widget.diagnosisResult.imagePath),
                                      fit: BoxFit.cover,
                                    )
                              : Icon(
                                  Icons.image,
                                  size: 30,
                                  color: Colors.grey.shade500,
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Diagnosis Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.diagnosisResult.namaPenyakit,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Akurasi: ${(widget.diagnosisResult.confidence * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Treatment Recommendation Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.eco_outlined,
                      size: 20,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Rekomendasi Perawatan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                recommendation,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 40),

              // Confirm Button (only show for new diagnoses)
              if (!widget.fromHistory)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveDiagnosis,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Menyimpan...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Konfirmasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
