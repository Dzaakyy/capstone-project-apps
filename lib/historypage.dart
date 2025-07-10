import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/diagnosiscore.dart';
import 'package:frontend/diagnosispage.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HistoryPage({super.key, required this.cameras});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<DiagnosisResult>> _allHistoryFuture;

  @override
  void initState() {
    super.initState();
    _allHistoryFuture = DiagnosisService.fetchUserHistory();
  }

  void _refreshAllHistory() {
    setState(() {
      _allHistoryFuture = DiagnosisService.fetchUserHistory();
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Tanggal tidak tersedia';
    return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Riwayat Diagnosis'),
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshAllHistory(),
        child: FutureBuilder<List<DiagnosisResult>>(
          future: _allHistoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error}',
                    textAlign: TextAlign.center),
              ));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_toggle_off,
                        size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Tidak ada riwayat diagnosis.',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              );
            }

            final histories = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: histories.length,
              separatorBuilder: (context, index) => const Divider(
                thickness: 1, 
                height: 1, 
              ),
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
                    ).then((_) => _refreshAllHistory());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            history.imagePath,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(history.tanggalDiagnosis),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                history.namaPenyakit,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
