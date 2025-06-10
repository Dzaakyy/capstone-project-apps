import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/diagnosiscore.dart';
import 'package:camera/camera.dart';
import 'package:frontend/perawatanpage.dart';

class DiagnosisPage extends StatefulWidget {
  final DiagnosisResult diagnosisResult;
  final List<CameraDescription> cameras; 
  
  const DiagnosisPage({
    super.key,
    required this.diagnosisResult,
    required this.cameras,
  });

  @override
  State<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<DiagnosisPage> {

  void _navigateToRecommendation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RekomendasiPerawatanPage(
          diagnosisResult: widget.diagnosisResult,
          cameras: widget.cameras, 
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            size: 22,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Diagnosis',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Handle menu action
            },
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
              size: 22,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.diagnosisResult.prediction,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Akurasi: ${(widget.diagnosisResult.confidence * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black87,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: widget.diagnosisResult.imagePath.isNotEmpty
                      ? Image.file(
                          File(widget.diagnosisResult.imagePath),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Icon(
                    Icons.coronavirus_outlined,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Gejala',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  'Gejala akan ditampilkan di sini sesuai dengan data dari backend...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Info lebih lanjut',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  'Info lebih lanjut akan ditampilkan di sini sesuai dengan data dari backend...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToRecommendation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Konfirmasi & lihat pengobatan',
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

