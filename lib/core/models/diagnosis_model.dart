class DiagnosisResult {
  final String prediction;
  final double confidence;
  final String imagePath; 
  final String namaPenyakit;
  final String golongan;
  final String namaIlmiah;
  final String gejala;
  final String rekomendasiPerawatan;
  final int idPrediksi;
  final DateTime? tanggalDiagnosis;
  final String? error; 
  final String? message;

  DiagnosisResult({
    required this.prediction,
    required this.confidence,
    required this.imagePath,
    required this.namaPenyakit,
    required this.golongan,
    required this.namaIlmiah,
    required this.gejala,
    required this.rekomendasiPerawatan,
    required this.idPrediksi,
    this.tanggalDiagnosis,
    this.error,
    this.message
  });

  factory DiagnosisResult.fromJson(
      Map<String, dynamic> json, String imagePath) {
    return DiagnosisResult(
      prediction: json['prediksi']?['prediksi'] ?? 'Unknown',
      confidence: (json['prediksi']?['akurasi'] ?? 0.0).toDouble(),
      imagePath: json['prediksi']?['imageUrl'] ?? imagePath,
      namaPenyakit: json['penyakit']?['nama_penyakit'] ?? 'Unknown',
      golongan: json['penyakit']?['golongan'] ?? 'Unknown',
      namaIlmiah: json['penyakit']?['nama_ilmiah'] ?? 'Unknown',
      gejala: json['penyakit']?['gejala'] ?? 'Tidak ada informasi gejala',
      rekomendasiPerawatan:
          json['penyakit']?['rekomendasi_perawatan'] ?? 'Tidak ada rekomendasi',
      idPrediksi: json['prediksi']?['id_prediksi'] ?? 0,
      tanggalDiagnosis: json['tanggal_diagnosis'] != null
          ? DateTime.parse(json['tanggal_diagnosis'])
          : null,
          error: json['error'], 
      message: json['message'], 
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'confidence': confidence,
      'imagePath': imagePath,
      'namaPenyakit': namaPenyakit,
      'golongan': golongan,
      'namaIlmiah': namaIlmiah,
      'gejala': gejala,
      'rekomendasiPerawatan': rekomendasiPerawatan,
      'idPrediksi': idPrediksi,
      'tanggalDiagnosis': tanggalDiagnosis?.toIso8601String(),
      'error': error,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

