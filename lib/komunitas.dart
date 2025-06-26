import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'komunitascore.dart';
import 'tanyakomunitas.dart';
import 'komunitasdetailscreen.dart';

final logger = Logger();

class KomunitasScreen extends StatefulWidget {
  const KomunitasScreen({super.key});

  @override
  State<KomunitasScreen> createState() => _KomunitasScreenState();
}

class _KomunitasScreenState extends State<KomunitasScreen> {
  List<Komunitas> komunitasList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchKomunitas();
  }

  Future<void> fetchKomunitas() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Token tidak ditemukan, silakan login kembali')),
          );
        }
        setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/komunitas'),
        headers: {'Authorization': 'Bearer $token'},
      );

      logger.i('Fetch Komunitas Status: ${response.statusCode}');
      logger.i('Fetch Komunitas Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            komunitasList = data.map((json) => Komunitas.fromJson(json)).toList();
            isLoading = false;
          });
          logger.i('Fetched ${komunitasList.length} posts');
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Sesi login habis, silakan login kembali')),
          );
        }
        setState(() => isLoading = false);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat data: ${response.statusCode}')),
          );
        }
        setState(() => isLoading = false);
      }
    } catch (e) {
      logger.e('Error fetching komunitas: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan jaringan: $e')),
        );
      }
      setState(() => isLoading = false);
    }
  }

  Future<int> fetchTotalKomentar(int postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) return 0;

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/komunitas/$postId/komentar'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['totalKomentar'] ?? 0;
      }
      return 0;
    } catch (e) {
      logger.e('Error fetching total komentar: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Komunitas'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
            },
            color: Colors.black,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : komunitasList.isEmpty
              ? const Center(child: Text('Tidak ada postingan'))
              : RefreshIndicator(
                  onRefresh: fetchKomunitas,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: komunitasList.length,
                    itemBuilder: (context, index) {
                      final post = komunitasList[index];
                      return FutureBuilder<int>(
                        future: fetchTotalKomentar(post.idKomunitas!),
                        builder: (context, snapshot) {
                          final totalKomentar = snapshot.data ?? 0;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        KomunitasDetailScreen(post: post),
                                  ),
                                );
                                setState(() {});
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (post.image != null && post.image!.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(12)),
                                      child: CachedNetworkImage(
                                        imageUrl: post.image!,
                                        placeholder: (context, url) =>
                                            const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                        errorWidget: (context, url, error) {
                                          logger.e('Image load error: $url, $error');
                                          return const Icon(Icons.error,
                                              size: 50);
                                        },
                                        width: double.infinity,
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.username ?? 'Anonymous',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        if (post.judul != null &&
                                            post.judul!.isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 15),
                                            child: Text(
                                              post.judul!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 11),
                                        Text(
                                          post.isi,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(height: 11),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '$totalKomentar Jawaban',
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.thumb_up),
                                              onPressed: () {
                                              },
                                              iconSize: 18,
                                              color: Colors.grey,
                                            ),
                                            Text('${post.likeCount ?? 0}'),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.thumb_down),
                                              onPressed: () {
                                              },
                                              iconSize: 18,
                                              color: Colors.grey,
                                            ),
                                            Text('${post.dislikeCount ?? 0}'),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const TanyaKomunitasPage()),
          ).then((_) => fetchKomunitas());
        },
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}