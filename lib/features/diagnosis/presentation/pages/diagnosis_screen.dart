import 'package:flutter/material.dart';
import 'package:frontend/core/models/diagnosis_model.dart';
import 'package:camera/camera.dart';
import 'package:frontend/features/diagnosis/presentation/pages/perawatan_screen.dart';
import 'dart:io';

class DiagnosisPage extends StatefulWidget {
  final DiagnosisResult diagnosisResult;
  final List<CameraDescription> cameras;
  final bool showBackButton;
  final bool fromHistory;

  const DiagnosisPage({
    super.key,
    required this.diagnosisResult,
    required this.cameras,
    this.showBackButton = false,
    this.fromHistory = false
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
          recommendationText: widget.diagnosisResult.rekomendasiPerawatan,
          fromHistory: widget.fromHistory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.diagnosisResult.imagePath.isNotEmpty;
    final isNetwork = hasImage && widget.diagnosisResult.imagePath.startsWith('http');

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          // Background Hero Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: hasImage
                ? (isNetwork
                    ? Image.network(
                        widget.diagnosisResult.imagePath,
                        fit: BoxFit.cover,
                      )
                    : Image.file(
                        File(widget.diagnosisResult.imagePath),
                        fit: BoxFit.cover,
                      ))
                : Container(
                    color: Colors.green.shade800,
                    child: const Center(
                      child: Icon(Icons.eco, size: 80, color: Colors.white54),
                    ),
                  ),
          ),
          
          // Image Gradient Overlay
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

          // Custom App Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.showBackButton)
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
                  'Diagnosis Result',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 40), // Balance
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
                  // Handle bar
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
                          // Header Info
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.diagnosisResult.namaPenyakit,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1F2C),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.category_rounded, size: 14, color: Colors.blue.shade700),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.diagnosisResult.golongan,
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.diagnosisResult.namaIlmiah,
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Symptoms Section
                          _buildSectionTitle(Icons.coronavirus_rounded, 'Symptoms'),
                          const SizedBox(height: 12),
                          _buildCardInfo(widget.diagnosisResult.gejala),

                          const SizedBox(height: 40),
                          
                          // Action Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _navigateToRecommendation,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF22C55E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'View Treatment Plan',
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
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Colors.red.shade600),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F2C),
          ),
        ),
      ],
    );
  }

  Widget _buildCardInfo(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        content,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 15,
          height: 1.6,
        ),
      ),
    );
  }
}
