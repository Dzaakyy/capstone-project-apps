import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

import 'package:frontend/core/models/komunitas_model.dart';
import 'package:frontend/core/models/komentar_model.dart';
import 'package:frontend/features/community/presentation/bloc/community_bloc.dart';
import 'package:frontend/features/community/presentation/bloc/community_event.dart';
import 'package:frontend/features/community/presentation/bloc/community_state.dart';

final logger = Logger();

class KomunitasDetailScreen extends StatefulWidget {
  final Komunitas post;

  const KomunitasDetailScreen({super.key, required this.post});

  @override
  State<KomunitasDetailScreen> createState() => _KomunitasDetailScreenState();
}

class _KomunitasDetailScreenState extends State<KomunitasDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    context.read<CommunityBloc>().add(CommentsFetchRequested(widget.post.idKomunitas!));
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserIdInt = prefs.getInt('idUser');
      if (storedUserIdInt != null) {
        if (mounted) {
          setState(() {
            currentUserId = storedUserIdInt.toString();
          });
        }
      }
    } catch (e) {
      logger.e('Error loading userId: $e');
    }
  }

  void _submitKomentar() {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan komentar Anda'), backgroundColor: Colors.red),
      );
      return;
    }
    context.read<CommunityBloc>().add(CommentAddRequested(widget.post.idKomunitas!, _commentController.text));
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  void _updateKomentar(int komentarId, String newText) {
    if (newText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan masukkan komentar Anda'), backgroundColor: Colors.red),
      );
      return;
    }
    context.read<CommunityBloc>().add(CommentUpdateRequested(komentarId, widget.post.idKomunitas!, newText));
  }

  void _deleteKomentar(int komentarId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus komentar ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CommunityBloc>().add(CommentDeleteRequested(komentarId, widget.post.idKomunitas!));
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditCommentDialog(Komentar komentar) {
    final editController = TextEditingController(text: komentar.isiKomentar);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Edit Komentar', style: TextStyle(color: Colors.black)),
          content: TextField(
            controller: editController,
            autofocus: true,
            maxLines: 3,
            style: const TextStyle(color: Colors.black),
            cursorColor: Colors.black,
            decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black45)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                if (komentar.idKomentar != null) {
                  _updateKomentar(komentar.idKomentar!, editController.text);
                }
              },
              child: const Text('Simpan', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Keluhan'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: BlocConsumer<CommunityBloc, CommunityState>(
        listener: (context, state) {
          if (state is CommunityActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          } else if (state is CommunityError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              if (state is CommunityLoading) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<CommunityBloc>().add(CommentsFetchRequested(widget.post.idKomunitas!));
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPostDetails(),
                        const SizedBox(height: 24),
                        _buildCommentSection(state),
                      ],
                    ),
                  ),
                ),
              ),
              _buildCommentInput(state is CommunityLoading),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostDetails() {
    return Column(
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
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const Center(child: CircularProgressIndicator()),
              errorBuilder: (context, error, stack) => const Icon(Icons.error, size: 50),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            widget.post.username ?? 'Anonymous',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        if (widget.post.judul != null && widget.post.judul!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.post.judul!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        const SizedBox(height: 16),
        Text(widget.post.isi, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildCommentSection(CommunityState state) {
    List<Komentar> komentarList = [];
    if (state is CommentsLoaded) {
      komentarList = state.comments;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jawaban (${komentarList.length} Komentar)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        if (state is CommunityLoading && komentarList.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (komentarList.isEmpty)
          const Center(child: Text('Belum ada jawaban', style: TextStyle(color: Colors.grey)))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: komentarList.length,
            itemBuilder: (context, index) {
              final komentar = komentarList[index];
              final isOwner = currentUserId != null && currentUserId == komentar.userId?.toString();

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
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          if (isOwner)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                  onPressed: (state is CommunityLoading) ? null : () => _showEditCommentDialog(komentar),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: (state is CommunityLoading) ? null : () => _deleteKomentar(komentar.idKomentar!),
                                ),
                              ],
                            ),
                        ],
                      ),
                      Text(
                        komentar.tanggalKomentar != null
                            ? DateFormat('dd-MM-yyyy HH:mm').format(komentar.tanggalKomentar!)
                            : '',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(komentar.isiKomentar, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCommentInput(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
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
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: isLoading ? null : _submitKomentar,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.all(12),
              shape: const CircleBorder(),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
