import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import 'dart:async';
import 'komunitascore.dart';
import 'komunitasdetailscreen.dart';
import 'editpostscreen.dart';

final logger = Logger();

class UserPostsScreen extends StatefulWidget {
  const UserPostsScreen({super.key});

  @override
  State<UserPostsScreen> createState() => _UserPostsScreenState();
}

class _UserPostsScreenState extends State<UserPostsScreen> {
  List<Komunitas> userPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserPosts();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchUserPosts() async {
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
        Uri.parse('http://10.0.2.2:3000/api/postingan/user'),
        headers: {'Authorization': 'Bearer $token'},
      );

      logger.i('Fetch User Posts Status: ${response.statusCode}');
      logger.i('Fetch User Posts Response: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (mounted) {
          setState(() {
            if (data is List) {
              userPosts = data.map((json) => Komunitas.fromJson(json)).toList();
            } else if (data is Map && data['data'] != null) {
              userPosts = (data['data'] as List)
                  .map((json) => Komunitas.fromJson(json))
                  .toList();
            } else {
              userPosts = [];
            }
            isLoading = false;
          });
          logger.i('Fetched ${userPosts.length} user posts');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Gagal memuat postingan pengguna: ${response.statusCode}')),
          );
        }
        setState(() => isLoading = false);
      }
    } catch (e) {
      logger.e('Error fetching user posts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan jaringan: $e')),
        );
      }
      setState(() => isLoading = false);
    }
  }

  Future<void> deletePost(int postId) async {
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
        return;
      }

      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/api/komunitas/$postId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            userPosts.removeWhere((post) => post.idKomunitas == postId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Postingan berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Gagal menghapus postingan: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      logger.e('Error deleting post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan jaringan: $e')),
        );
      }
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
        title: const Text('Postingan Saya'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
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
                : userPosts.isEmpty
                    ? const Center(child: Text('Tidak ada postingan pengguna'))
                    : RefreshIndicator(
                        onRefresh: fetchUserPosts,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: userPosts.length,
                          itemBuilder: (context, index) {
                            final post = userPosts[index];
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
                                      );
                                      setState(() {});
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (post.image != null &&
                                            post.image!.isNotEmpty)
                                          ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(12)),
                                            child: CachedNetworkImage(
                                              imageUrl: post.image!,
                                              placeholder: (context, url) =>
                                                  const Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) {
                                                logger.e(
                                                    'Image load error: $url, $error');
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
                                                  fontSize: 18,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              if (post.judul != null &&
                                                  post.judul!.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 15),
                                                  child: Text(
                                                    post.judul!,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 17,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              const SizedBox(height: 20),
                                              Text(
                                                post.isi,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                                maxLines: 5,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(height: 10),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        color: Colors.blue),
                                                    onPressed: () async {
                                                      final bool?
                                                          postWasUpdated =
                                                          await Navigator.push<
                                                              bool>(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditPostScreen(
                                                                  post: post),
                                                        ),
                                                      );

                                                      if (postWasUpdated ==
                                                          true) {
                                                        fetchUserPosts();
                                                      }
                                                    },
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            AlertDialog(
                                                          title: const Text(
                                                              'Konfirmasi'),
                                                          content: const Text(
                                                              'Apakah Anda yakin ingin menghapus postingan ini?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                      context),
                                                              child: const Text(
                                                                  'Batal'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                                deletePost(post
                                                                    .idKomunitas!);
                                                              },
                                                              child: const Text(
                                                                'Hapus',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .red),
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
                                                '$totalKomentar Jawaban',
                                                style: const TextStyle(
                                                    color: Colors.blue,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
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
    );
  }
}
