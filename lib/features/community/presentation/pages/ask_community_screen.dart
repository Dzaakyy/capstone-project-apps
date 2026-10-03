import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/community/presentation/bloc/community_bloc.dart';
import 'package:frontend/features/community/presentation/bloc/community_event.dart';
import 'package:frontend/features/community/presentation/bloc/community_state.dart';
import 'package:frontend/core/utils/snackbar_util.dart';

class TanyaKomunitasPage extends StatefulWidget {
  const TanyaKomunitasPage({super.key});

  @override
  State<TanyaKomunitasPage> createState() => _TanyaKomunitasPageState();
}

class _TanyaKomunitasPageState extends State<TanyaKomunitasPage> {
  final _questionController = TextEditingController();
  final _descriptionController = TextEditingController();
  XFile? _pickedFile;

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

  void _submitQuestion() {
    if (_questionController.text.isEmpty) {
      SnackbarUtil.showError(context, 'Silakan masukkan pertanyaan Anda');
      return;
    }

    if (_descriptionController.text.isEmpty) {
      SnackbarUtil.showError(context, 'Silakan masukkan deskripsi masalah');
      return;
    }

    if (_pickedFile == null) {
      SnackbarUtil.showError(context, 'Silakan pilih gambar terlebih dahulu');
      return;
    }

    BlocProvider.of<CommunityBloc>(context).add(
      PostCreateRequested(
        _questionController.text,
        _descriptionController.text,
        File(_pickedFile!.path),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Tanya Komunitas', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<CommunityBloc, CommunityState>(
        listener: (context, state) {
          if (state is CommunityActionSuccess) {
            SnackbarUtil.showSuccess(context, state.message);

            _questionController.clear();
            _descriptionController.clear();
            setState(() {
              _pickedFile = null;
            });

            Navigator.pop(context);
          } else if (state is CommunityError) {
            SnackbarUtil.showError(context, 'Gagal: ${state.message}');
          }
        },
        builder: (context, state) {
          final isLoading = state is CommunityLoading;

          return isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.blue))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100, width: 2),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            if (_pickedFile == null)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Icon(Icons.add_photo_alternate_rounded, size: 64, color: Colors.grey.shade300),
                              )
                            else
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  File(_pickedFile!.path),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _pickedFile == null ? Colors.blue.shade600 : Colors.white,
                                foregroundColor: _pickedFile == null ? Colors.white : Colors.blue.shade700,
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: _pickedFile == null ? BorderSide.none : BorderSide(color: Colors.blue.shade100, width: 2),
                                ),
                                elevation: _pickedFile == null ? 4 : 0,
                                shadowColor: Colors.blue.withOpacity(0.3),
                              ),
                              icon: Icon(_pickedFile == null ? Icons.camera_alt_rounded : Icons.cameraswitch_rounded),
                              label: Text(
                                _pickedFile == null ? 'Upload Foto Tanaman' : 'Ganti Foto',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Pertanyaan Anda',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _questionController,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Misal: Kenapa daun monstera saya menguning?',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
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
                      const Text(
                        'Deskripsi Masalah',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Jelaskan ciri-ciri khususnya seperti perubahan daun, warna, serangga, dll.',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
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
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            )
                          ]
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _submitQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                )
                              : const Text(
                                  'Kirim Pertanyaan',
                                  style: TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
        },
      ),
    );
  }
}
