import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/models/komunitas_model.dart';
import 'package:frontend/features/community/presentation/bloc/community_bloc.dart';
import 'package:frontend/features/community/presentation/bloc/community_event.dart';
import 'package:frontend/features/community/presentation/bloc/community_state.dart';
import 'package:frontend/core/utils/snackbar_util.dart';

class EditPostScreen extends StatefulWidget {
  final Komunitas post;
  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late TextEditingController _questionController;
  late TextEditingController _descriptionController;
  XFile? _pickedFile;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.post.judul);
    _descriptionController = TextEditingController(text: widget.post.isi);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() => _pickedFile = pickedFile);
    }
  }

  void _updatePost() {
    if (_questionController.text.isEmpty) {
      SnackbarUtil.showWarning(context, 'Judul tidak boleh kosong');
      return;
    }
    File? imageFile = _pickedFile != null ? File(_pickedFile!.path) : null;
    context.read<CommunityBloc>().add(
      PostUpdateRequested(
        widget.post,
        _questionController.text,
        _descriptionController.text,
        imageFile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state is CommunityActionSuccess) {
          SnackbarUtil.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is CommunityError) {
          SnackbarUtil.showError(context, 'Gagal memperbarui: ${state.message}');
        }
      },
      builder: (context, state) {
        final isLoading = state is CommunityLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Edit Postingan',
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.blue))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image preview section
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100, width: 2),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _buildImagePreview(),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.blue.shade700,
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.blue.shade100, width: 2),
                                ),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.cameraswitch_rounded),
                              label: const Text(
                                'Ganti Foto',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Judul
                      const Text(
                        'Judul Pertanyaan',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _questionController,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Masukkan judul pertanyaan',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(20),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),

                      // Deskripsi
                      const Text(
                        'Deskripsi Masalah',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Jelaskan detail masalah tanaman Anda',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(20),
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 40),

                      // Submit button
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _updatePost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Simpan Perubahan',
                            style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildImagePreview() {
    if (_pickedFile != null) {
      return Image.file(
        File(_pickedFile!.path),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (widget.post.image != null && widget.post.image!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.post.image!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: Colors.grey.shade100,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: Colors.grey.shade100,
          child: Center(child: Icon(Icons.broken_image_rounded, size: 50, color: Colors.grey.shade400)),
        ),
      );
    }
    return Container(
      height: 160,
      color: Colors.grey.shade100,
      child: Center(
        child: Icon(Icons.add_photo_alternate_rounded, size: 64, color: Colors.grey.shade300),
      ),
    );
  }
}
