import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'komunitascore.dart';
import 'komentarcore.dart';
import 'package:intl/intl.dart';

final logger = Logger();

class KomunitasDetailScreen extends StatefulWidget {
  final Komunitas post;

  const KomunitasDetailScreen({super.key, required this.post});

  @override
  State<KomunitasDetailScreen> createState() => _KomunitasDetailScreenState();
}

class _KomunitasDetailScreenState extends State<KomunitasDetailScreen> {
  List<Komentar> komentarList = [];
  bool isLoading = true;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchKomentar();
  }

  Future<void> fetchKomentar() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda perlu login terlebih dahulu')),
          );
        }
        setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:3000/api/komunitas/${widget.post.idKomunitas}/komentar'),
        headers: {'Authorization': 'Bearer $token'},
      );

      logger.i('Fetch Komentar Status: ${response.statusCode}');
      logger.i('Fetch Komentar Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            komentarList = (data['komentar'] as List)
                .map((json) => Komentar.fromJson(json))
                .toList();
            isLoading = false;
          });
          logger.i('Fetched ${komentarList.length} comments');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Gagal memuat komentar: ${response.statusCode}')),
          );
        }
        setState(() => isLoading = false);
      }
    } catch (e) {
      logger.e('Error fetching komentar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan jaringan: $e')),
        );
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> submitKomentar() async {
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan komentar Anda')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda perlu login terlebih dahulu')),
          );
        }
        setState(() => _isSubmitting = false);
        return;
      }

      final response = await http.post(
        Uri.parse(
            'http://10.0.2.2:3000/api/komunitas/${widget.post.idKomunitas}/komentar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'isi_komentar': _commentController.text}),
      );

      logger.i('Submit Komentar Status: ${response.statusCode}');
      logger.i('Submit Komentar Response: ${response.body}');

      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Komentar berhasil dikirim'),
              backgroundColor: Colors.green,
            ),
          );
          _commentController.clear();
          fetchKomentar(); // Refresh daftar komentar
        }
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Unknown error';
        logger.e('Error submitting comment: $errorMessage');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengirim komentar: $errorMessage')),
          );
        }
      }
    } catch (e) {
      logger.e('Error submitting komentar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Keluhan'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.post.image != null &&
                            widget.post.image!.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.post.image!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                logger.e(
                                    'Image load error: ${widget.post.image}, $error');
                                return const Icon(Icons.error, size: 50);
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            widget.post.username ?? 'Anonymous',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (widget.post.judul != null &&
                            widget.post.judul!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              widget.post.judul!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Text(
                          widget.post.isi,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Jawaban (${komentarList.length} Komentar)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (komentarList.isEmpty)
                          const Center(
                            child: Text(
                              'Belum ada jawaban',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: komentarList.length,
                            itemBuilder: (context, index) {
                              final komentar = komentarList[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        komentar.username ?? 'Anonymous',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                       const SizedBox(height: 4),
                                      Text(
                                        komentar.tanggalKomentar != null
                                            ? DateFormat('dd-MM-yyyy').format(
                                                komentar.tanggalKomentar!)
                                            : '',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        komentar.isiKomentar,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                     
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Masukkan komentar Anda',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : submitKomentar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(12),
                    shape: const CircleBorder(),
                    minimumSize: const Size(48, 48),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Icon(
                          Icons.send,
                          size: 24,
                          color: Colors.white,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
