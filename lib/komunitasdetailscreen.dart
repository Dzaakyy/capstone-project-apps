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
  bool isSubmitting = false;
  bool isDeleting = false;
  final TextEditingController _commentController = TextEditingController();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (mounted) setState(() => isLoading = true);
    await _loadUserId();
    await fetchKomentar();
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserIdInt = prefs.getInt('idUser');
      final token = prefs.getString('accessToken');

      logger.i('Stored idUser: $storedUserIdInt, accessToken: $token');

      if (storedUserIdInt == null || token == null) {
        logger.w("Key 'idUser' or 'accessToken' not found in SharedPreferences.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Informasi pengguna tidak ditemukan. Silakan login kembali.')),
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          currentUserId = storedUserIdInt.toString();
        });
        logger.i("Successfully loaded userId: $currentUserId");
      }
    } catch (e) {
      logger.e('Error loading userId: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat informasi pengguna: $e')),
        );
      }
    }
  }

  Future<void> fetchKomentar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda perlu login terlebih dahulu')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/komunitas/${widget.post.idKomunitas}/komentar'),
        headers: {'Authorization': 'Bearer $token'},
      );

      logger.i('Fetch Komentar Status: ${response.statusCode}');
      logger.i('Fetch Komentar Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            if (data['komentar'] != null && data['komentar'] is List) {
              komentarList = (data['komentar'] as List)
                  .map((json) => Komentar.fromJson(json))
                  .toList();
            } else {
              komentarList = [];
            }
          });
          logger.i('Fetched ${komentarList.length} comments');
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sesi login habis, silakan login kembali')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat komentar: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      logger.e('Error fetching komentar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan jaringan: $e')),
        );
      }
    }
  }

  Future<void> submitKomentar() async {
    if (_commentController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan masukkan komentar Anda')),
        );
      }
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda perlu login terlebih dahulu')),
          );
        }
        setState(() => isSubmitting = false);
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/komunitas/${widget.post.idKomunitas}/komentar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'isi_komentar': _commentController.text}),
      );


      if (response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Komentar berhasil dikirim'),
              backgroundColor: Colors.green,
            ),
          );
          _commentController.clear();
          await fetchKomentar();
        }
      } else {
        final errorMessage = json.decode(response.body)['error'] ?? 'Unknown error';
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
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  Future<void> deleteKomentar(int komentarId) async {
    setState(() => isDeleting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda perlu login terlebih dahulu')),
          );
        }
        setState(() => isDeleting = false);
        return;
      }

   

      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/api/komunitas/komentar/$komentarId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      logger.i('Delete Komentar Status: ${response.statusCode}');
      logger.i('Delete Komentar Response: ${response.body}');

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            komentarList.removeWhere((komentar) => komentar.idKomentar == komentarId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Komentar berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          await fetchKomentar();
        }
      } else {
        final errorMessage = json.decode(response.body)['error'] ?? 'Unknown error';
        logger.e('Error deleting comment: $errorMessage');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus komentar: $errorMessage')),
          );
        }
      }
    } catch (e) {
      logger.e('Error deleting komentar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan jaringan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isDeleting = false);
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
          if (isLoading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadInitialData,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.post.image != null && widget.post.image!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.post.image!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  logger.e('Image load error: ${widget.post.image}, $error');
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
                          if (widget.post.judul != null && widget.post.judul!.isNotEmpty)
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
                          komentarList.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Belum ada jawaban',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: komentarList.length,
                                  itemBuilder: (context, index) {
                                    final komentar = komentarList[index];
                                    final isOwner = currentUserId != null &&
                                        currentUserId == komentar.userId?.toString();
                                    logger.i(
                                        'Comment ${komentar.idKomentar}: userId=${komentar.userId}, currentUserId=$currentUserId, isOwner=$isOwner');

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  komentar.username ?? 'Anonymous',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                if (isOwner)
                                                  IconButton(
                                                    icon: isDeleting
                                                        ? const SizedBox(
                                                            width: 24,
                                                            height: 24,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color: Colors.red,
                                                            ),
                                                          )
                                                        : const Icon(Icons.delete, color: Colors.red),
                                                    onPressed: isDeleting
                                                        ? null
                                                        : () {
                                                            showDialog(
                                                              context: context,
                                                              builder: (context) => AlertDialog(
                                                                title: const Text('Konfirmasi'),
                                                                content: const Text(
                                                                    'Apakah Anda yakin ingin menghapus komentar ini?'),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () => Navigator.pop(context),
                                                                    child: const Text('Batal'),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () {
                                                                      Navigator.pop(context);
                                                                      if (komentar.idKomentar != null) {
                                                                        deleteKomentar(komentar.idKomentar!);
                                                                      } else {
                                                                        logger.e('Error: komentar.idKomentar is null');
                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                          const SnackBar(
                                                                              content: Text(
                                                                                  'Gagal menghapus: ID komentar tidak valid')),
                                                                        );
                                                                      }
                                                                    },
                                                                    child: const Text(
                                                                      'Hapus',
                                                                      style: TextStyle(color: Colors.red),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                  ),
                                              ],
                                            ),
                                            Text(
                                              komentar.tanggalKomentar != null
                                                  ? DateFormat('dd-MM-yyyy HH:mm')
                                                      .format(komentar.tanggalKomentar!)
                                                  : '',
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
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
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey[200],
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isSubmitting ? null : submitKomentar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(12),
                    shape: const CircleBorder(),
                    minimumSize: const Size(48, 48),
                  ),
                  child: isSubmitting
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