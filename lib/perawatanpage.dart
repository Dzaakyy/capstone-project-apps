import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/diagnosiscore.dart';

class RekomendasiPerawatanPage extends StatefulWidget {
  final DiagnosisResult diagnosisResult;
  final String recommendationText;
  
  const RekomendasiPerawatanPage({
    super.key,
    required this.diagnosisResult,
    this.recommendationText = '',
  });

  @override
  State<RekomendasiPerawatanPage> createState() => _RekomendasiPerawatanPageState();
}

class _RekomendasiPerawatanPageState extends State<RekomendasiPerawatanPage> {
  bool _isSaving = false;

  String get _currentDate {
    final now = DateTime.now();
    final months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${now.day} ${months[now.month]}';
  }

  String get _defaultRecommendation {
    return 'Untuk mengatasi bercak hitam bakteri pada mangga, gunakan bakterisida berbasis tembaga seperti tembaga hidroksida atau tembaga oksiklorida dengan dosis 2-3 g per liter air, lalu semprotkan setiap 7-10 hari pada pagi atau sore hari pada awal musim hujan, sesuai Extensionist University of Florida (2020). Spot Management". Pastikan untuk membuang dan membakar daun yang terinfeksi untuk mencegah penyebaran bakteri, seperti dianjurkan oleh FAO Plant Production and Protection Division (2018). Selain itu, siram tanaman di pangkal batang, hindari daun, dan pastikan drainase yang baik untuk mengurangi kelembaban berlebih di Queensland Government Department of Agriculture and Fisheries (2019). Untuk pencegahan jangka panjang, gunakan varietas mangga yang tahan terhadap penyakit atau "Ketti" untuk pencegahan, sesuai studi di Journal of Phytopathology (2019), serta pangkas cabang yang terinfeksi setiap 2-3 bulan untuk meningkatkan sirkulasi udara. Jika infeksi parah, konsultasikan dengan ahli pertanian atau gunakan UC ANR dalam "Mango Pest and Disease Management" (2020).';
  }

  Future<void> _saveDiagnosis() async {
    setState(() {
      _isSaving = true;
    });

    try {
      bool saveSuccess = await DiagnosisService.saveDiagnosis(widget.diagnosisResult);
      
      if (saveSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Diagnosis berhasil disimpan'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          _showErrorSnackBar('Gagal menyimpan diagnosis. Silakan coba lagi.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
    final recommendation = widget.recommendationText.isNotEmpty 
        ? widget.recommendationText 
        : _defaultRecommendation;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: _isSaving ? null : () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.black),
        ),
        title: Text(
          _currentDate,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : () {
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
              // Hasil Diagnosis Section
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
              
              // Diagnosis Result Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Image
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
                            ? Image.file(
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
                    
                    // Diagnosis Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.diagnosisResult.prediction,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bakteri',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Arrow Icon
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
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
                          'Simpan ke diagnosis anda',
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

