import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'dart:async';
import 'komunitascore.dart';
import 'tanyakomunitas.dart';
import 'komunitasdetailscreen.dart';
import 'userpostscreen.dart';

final logger = Logger();

class KomunitasScreen extends StatefulWidget {
  const KomunitasScreen({super.key});

  @override
  State<KomunitasScreen> createState() => _KomunitasScreenState();
}

class _KomunitasScreenState extends State<KomunitasScreen> {
  List<Komunitas> komunitasList = [];
  List<Komunitas> filteredKomunitasList = [];
  bool isLoading = true;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    fetchKomunitas();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchKomunitas() async {
    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Token tidak ditemukan, silakan login kembali')),
          );
        }
        setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.0.105:3000/api/komunitas'),
        headers: {'Authorization': 'Bearer $token'},
      );

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
            const SnackBar(content: Text('Sesi login habis, silakan login kembali')),
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

  Future<void> searchKomunitas(String query) async {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        filteredKomunitasList = [];
      });
      return;
    }

    setState(() => isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Token tidak ditemukan, silakan login kembali')),
          );
        }
        setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('http://192.168.0.105:3000/api/komunitas/cari?query=$query'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (mounted) {
          setState(() {
            filteredKomunitasList = data.map((json) => Komunitas.fromJson(json)).toList();
            isSearching = true;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal melakukan pencarian: ${response.statusCode}')),
          );
        }
        setState(() => isLoading = false);
      }
    } catch (e) {
      logger.e('Error searching komunitas: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan jaringan: $e')),
        );
      }
      setState(() => isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      searchKomunitas(query);
    });
  }

  Future<int> fetchTotalKomentar(int postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) return 0;

      final response = await http.get(
        Uri.parse('http://192.168.0.105:3000/api/komunitas/$postId/komentar'),
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
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 1),
              )
            ],
          ),
          padding: const EdgeInsets.only(top: 10),
          child: SafeArea(
            child: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              title: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(color: Colors.black, width: 1.0),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari Keluhan Tanaman',
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 15.0,
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                
                  IconButton(
                    icon: const Icon(Icons.list_rounded),
                    color: Colors.black,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserPostsScreen()),
                      ).then((_) async {
                        if (mounted) {
                          await fetchKomunitas(); 
                        }
                      });
                    },
                  ),
                ],
              ),
              automaticallyImplyLeading: false,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (isLoading && isSearching) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: isLoading && !isSearching
                ? const Center(child: CircularProgressIndicator())
                : (isSearching ? filteredKomunitasList : komunitasList).isEmpty
                    ? Center(
                        child: Text(
                          isSearching
                              ? 'Tidak ditemukan hasil pencarian'
                              : 'Tidak ada postingan',
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchKomunitas,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: isSearching
                              ? filteredKomunitasList.length
                              : komunitasList.length,
                          itemBuilder: (context, index) {
                            final post = isSearching
                                ? filteredKomunitasList[index]
                                : komunitasList[index];
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
                                      )
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
                                      ).then((_) async {
                                        if (mounted) {
                                          await fetchKomunitas(); 
                                        }
                                      });
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (post.image != null && post.image!.isNotEmpty)
                                          ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                            child: CachedNetworkImage(
                                              imageUrl: post.image!,
                                              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                              errorWidget: (context, url, error) {
                                                logger.e('Image load error: $url, $error');
                                                return const Icon(Icons.error, size: 50);
                                              },
                                              width: double.infinity,
                                              height: 150,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post.username ?? 'Anonymous',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              if (post.judul != null && post.judul!.isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 15),
                                                  child: Text(
                                                    post.judul!,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 17,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              const SizedBox(height: 20),
                                              Text(
                                                post.isi,
                                                style: const TextStyle(fontSize: 14),
                                                maxLines: 5,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(height: 10),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const SizedBox.shrink(),
                                              Text(
                                                '$totalKomentar Jawaban',
                                                style: const TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TanyaKomunitasPage()),
          ).then((_) async {
            if (mounted) {
              await fetchKomunitas(); 
            }
          });
        },
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}