import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import 'package:frontend/features/community/presentation/bloc/community_bloc.dart';
import 'package:frontend/features/community/presentation/bloc/community_event.dart';
import 'package:frontend/features/community/presentation/bloc/community_state.dart';
import 'package:frontend/features/community/presentation/pages/ask_community_screen.dart';
import 'package:frontend/features/community/presentation/pages/community_detail_screen.dart';
import 'package:frontend/features/community/presentation/pages/user_post_screen.dart';
import 'package:frontend/core/utils/snackbar_util.dart';

final logger = Logger();

class KomunitasScreen extends StatefulWidget {
  const KomunitasScreen({super.key});

  @override
  State<KomunitasScreen> createState() => _KomunitasScreenState();
}

class _KomunitasScreenState extends State<KomunitasScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _fetchKomunitas();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _fetchKomunitas() {
    BlocProvider.of<CommunityBloc>(context).add(PostsFetchRequested());
  }

  void _searchKomunitas(String query) {
    if (query.isEmpty) {
      _fetchKomunitas();
      return;
    }
    BlocProvider.of<CommunityBloc>(context).add(PostsSearchRequested(query));
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) return '${diff.inMinutes} menit lalu';
      return '${diff.inHours} jam lalu';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    }
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  void _onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _searchKomunitas(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      extendBodyBehindAppBar: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari Keluhan Tanaman',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade500),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded, color: Colors.grey.shade500),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14.0,
                            horizontal: 16.0,
                          ),
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.person_outline_rounded),
                      color: Colors.blue.shade700,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UserPostsScreen()),
                        ).then((_) {
                          if (mounted) {
                            _fetchKomunitas(); 
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
              automaticallyImplyLeading: false,
            ),
          ),
        ),
      ),
      body: BlocBuilder<CommunityBloc, CommunityState>(
        builder: (context, state) {
          if (state is CommunityLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          } else if (state is CommunityError) {
            return Center(child: Text(state.message, style: TextStyle(color: Colors.grey.shade600)));
          } else if (state is PostsLoaded) {
            final komunitasList = state.posts;

            if (komunitasList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.isNotEmpty
                          ? 'Tidak ditemukan hasil pencarian'
                          : 'Belum ada postingan',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                if (_searchController.text.isNotEmpty) {
                  _searchKomunitas(_searchController.text);
                } else {
                  _fetchKomunitas();
                }
              },
              child: ListView.builder(
                // Padding bawah ekstra agar item terakhir tidak tertutup FAB + floating nav
                padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 160),
                itemCount: komunitasList.length,
                itemBuilder: (context, index) {
                  final post = komunitasList[index];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          spreadRadius: 0,
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => KomunitasDetailScreen(post: post),
                            ),
                          ).then((_) {
                            if (mounted) {
                              if (_searchController.text.isEmpty) {
                                  _fetchKomunitas(); 
                              } else {
                                  _searchKomunitas(_searchController.text);
                              }
                            }
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (post.image != null && post.image!.isNotEmpty)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: CachedNetworkImage(
                                  imageUrl: post.image!,
                                  placeholder: (context, url) => Container(
                                    height: 160,
                                    color: Colors.grey.shade50,
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) {
                                    logger.e('Image load error: $url, $error');
                                    return Container(
                                      height: 160,
                                      color: Colors.grey.shade50,
                                      child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey.shade400),
                                    );
                                  },
                                  width: double.infinity,
                                  height: 160,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.blue.shade50,
                                        child: Text(
                                          (post.username ?? 'A')[0].toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post.username ?? 'Anonymous',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              post.tanggalPost != null
                                                  ? _formatDate(post.tanggalPost!)
                                                  : 'Baru saja',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  if (post.judul != null && post.judul!.isNotEmpty)
                                    Text(
                                      post.judul!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    post.isi,
                                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: Colors.grey.shade100)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.blue.shade600),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${post.commentCount} Jawaban',
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

