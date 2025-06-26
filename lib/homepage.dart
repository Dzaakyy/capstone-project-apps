import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/camerapage.dart';
import 'package:frontend/diagnosiscore.dart';
import 'package:frontend/diagnosispage.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomePage({super.key, required this.cameras});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<DiagnosisResult>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = DiagnosisService.fetchUserHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = DiagnosisService.fetchUserHistory();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Tanggal tidak tersedia';
    final formatter = DateFormat('dd MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Stack(
              children: [
                Container(
                  height: 280,
                  padding: const EdgeInsets.fromLTRB(16, 70, 16, 0),
                  decoration: BoxDecoration(
                      color: Colors.indigo.shade300,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      )),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Expanded(
                            flex: 1,
                            child: Text(
                              'Cek Kesehatan Tanaman Anda',
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Image.asset(
                              './lib/assets/mango.png',
                              height: 120,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 220, bottom: 30),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Icon(Icons.photo_camera_outlined),
                                    SizedBox(height: 4),
                                    Text(
                                      'Ambil\nGambar',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                Icon(Icons.chevron_right_rounded),
                                Column(
                                  children: [
                                    Icon(Icons.note_add_outlined),
                                    SizedBox(height: 4),
                                    Text(
                                      'Cek\nDiagnosis',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                                Icon(Icons.chevron_right_rounded),
                                Column(
                                  children: [
                                    Icon(Icons.energy_savings_leaf_outlined),
                                    SizedBox(height: 4),
                                    Text(
                                      'Rekomendasi\nPerawatan',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 20, 0, 20),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CameraPage(cameras: widget.cameras),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                    minimumSize: const Size(200, 50),
                                  ),
                                  child: const Text(
                                    'Ambil Gambar',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 500,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text(
                          'Diagnosis Anda',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        GestureDetector(
                          onTap: _refreshHistory,
                          child: Text(
                            'Lihat Semua',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<DiagnosisResult>>(
                      future: _historyFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 50),
                                const SizedBox(height: 16),
                                Text(
                                  'Gagal memuat riwayat',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  snapshot.error.toString(),
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _refreshHistory,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                  ),
                                  child: const Text(
                                    'Coba Lagi',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history,
                                    size: 50, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Belum ada riwayat diagnosis',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }

                        final histories = snapshot.data!;
                        return RefreshIndicator(
                          onRefresh: () async {
                            _refreshHistory();
                          },
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: histories.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 16),
                            itemBuilder: (context, index) {
                              final history = histories[index];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DiagnosisPage(
                                          diagnosisResult: history,
                                          cameras: widget.cameras,
                                          showBackButton: true,
                                          fromHistory: true),
                                    ),
                                  ).then((_) {
                                    // Refresh history after returning from diagnosis page
                                    _refreshHistory();
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      // Gambar Diagnosis
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.grey.shade200,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: history.imagePath.isNotEmpty
                                              ? Image.network(
                                                  history.imagePath,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, progress) {
                                                    if (progress == null)
                                                      return child;
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: progress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? progress
                                                                    .cumulativeBytesLoaded /
                                                                progress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                    );
                                                  },
                                                )
                                              : const Icon(
                                                  Icons.image,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Detail Diagnosis
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _formatDate(
                                                  history.tanggalDiagnosis),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              history.namaPenyakit,
                                              style: const TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
