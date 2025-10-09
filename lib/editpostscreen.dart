import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart' as mime;
import 'package:http_parser/http_parser.dart';
import 'komunitascore.dart'; // Sesuaikan dengan lokasi model Komunitas Anda

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
  bool _isLoading = false;
  final logger = Logger();

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
      setState(() {
        _pickedFile = pickedFile;
      });
    }
  }

  Future<void> _updatePost() async {
    if (_questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda perlu login terlebih dahulu')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      var request = http.MultipartRequest(
        'PUT', // Gunakan metode PUT untuk update
        Uri.parse(
            'http://192.168.0.105:3000/api/komunitas/${widget.post.idKomunitas}'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['judul'] = _questionController.text;
      request.fields['isi'] = _descriptionController.text;

      // Hanya kirim file jika pengguna memilih gambar baru
      if (_pickedFile != null) {
        var mimeType = mime.lookupMimeType(_pickedFile!.path) ?? 'image/jpeg';
        var file = await http.MultipartFile.fromPath(
          'image',
          _pickedFile!.path,
          contentType: MediaType.parse(mimeType),
          filename: _pickedFile!.name,
        );
        request.files.add(file);
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      logger.i('Update Status Code: ${response.statusCode}, Response: $responseData');

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Postingan berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          // Kembali ke halaman sebelumnya dan kirim sinyal sukses (true)
          Navigator.pop(context, true);
        }
      } else {
        var errorMessage = json.decode(responseData)['error'] ?? 'Unknown error';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui: $errorMessage'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      logger.e('Error during update: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Postingan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildImagePreview(),
                  const SizedBox(height: 8),
                  ElevatedButton(
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[800],
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.blue[800]!, width: 1.5),
                          ),
                          elevation: 3,
                          shadowColor: Colors.blue.withOpacity(0.3),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt, size: 24),
                            SizedBox(width: 12),
                            Text(
                              'Ganti Foto Tanaman',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  const SizedBox(height: 24),

                  const Text('Judul Pertanyaan', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan judul pertanyaan',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  
                  const Text('Deskripsi Masalah', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText: 'Jelaskan detail masalah tanaman Anda',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _updatePost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: const Text('Simpan Perubahan', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _pickedFile != null
            ? Image.file(
                File(_pickedFile!.path),
                fit: BoxFit.cover,
              )
            : (widget.post.image != null && widget.post.image!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.post.image!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  )
                : const Center(
                    child: Text('Tidak ada gambar', style: TextStyle(color: Colors.grey)),
                  )
              ),
      ),
    );
  }
}