import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:logger/logger.dart';

import 'package:frontend/features/community/presentation/bloc/community_bloc.dart';
import 'package:frontend/features/community/presentation/bloc/community_event.dart';
import 'package:frontend/features/community/presentation/bloc/community_state.dart';

import 'package:frontend/features/community/presentation/pages/ask_community_screen.dart';
import 'package:frontend/features/community/presentation/pages/community_detail_screen.dart';
import 'package:frontend/features/community/presentation/pages/user_post_screen.dart';

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

  void _onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _searchKomunitas(query);
    });
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
                      ).then((_) {
                        if (mounted) {
                          _fetchKomunitas(); 
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
      body: BlocBuilder<CommunityBloc, CommunityState>(
        builder: (context, state) {
          if (state is CommunityLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CommunityError) {
            return Center(child: Text(state.message));
          } else if (state is PostsLoaded) {
            final komunitasList = state.posts;

            if (komunitasList.isEmpty) {
              return Center(
                child: Text(
                  _searchController.text.isNotEmpty
                      ? 'Tidak ditemukan hasil pencarian'
                      : 'Tidak ada postingan',
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
                padding: const EdgeInsets.all(16),
                itemCount: komunitasList.length,
                itemBuilder: (context, index) {
                  final post = komunitasList[index];
                  // Removed FutureBuilder for comments, default to 0. 
                  // In a real application, total comments might be included in the Komunitas model from the backend.
                  final int totalKomentar = 0; 
                  
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
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TanyaKomunitasPage()),
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
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
