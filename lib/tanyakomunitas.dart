import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart' as mime;
import 'package:http_parser/http_parser.dart';

class TanyaKomunitasPage extends StatefulWidget {
  const TanyaKomunitasPage({super.key});

  @override
  State<TanyaKomunitasPage> createState() => _TanyaKomunitasPageState();
}

class _TanyaKomunitasPageState extends State<TanyaKomunitasPage> {
  final _questionController = TextEditingController();
  final _descriptionController = TextEditingController();
  XFile? _pickedFile; 
  bool _isLoading = false;
  final logger = Logger();

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

  Future<void> _submitQuestion() async {
  if (_questionController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Silakan masukkan pertanyaan Anda'),
      backgroundColor: Colors.red,),
    );
    return;
  }

  if (_pickedFile == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Silakan pilih gambar terlebih dahulu'),
      backgroundColor: Colors.red,),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Anda perlu login terlebih dahulu')),
        );
      }
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:3000/api/komunitas'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['judul'] = _questionController.text;
    request.fields['isi'] = _descriptionController.text;

    var mimeType = mime.lookupMimeType(_pickedFile!.path) ?? 'image/jpeg';
    logger.i('Mengirim file: ${_pickedFile!.path}, MIME Type: $mimeType');

    var file = await http.MultipartFile.fromPath(
      'image',
      _pickedFile!.path,
      contentType: mimeType != 'unknown' ? MediaType.parse(mimeType) : null,
      filename: _pickedFile!.name, 
    );
    request.files.add(file);

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    logger.i('Status Code: ${response.statusCode}, Response: $responseData');

    if (response.statusCode == 201) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pertanyaan berhasil dikirim ke komunitas'),
            backgroundColor: Colors.green,
          ),
        );

        _questionController.clear();
        _descriptionController.clear();
        setState(() {
          _pickedFile = null;
        });

        Navigator.pop(context);
      }
    } else {
      var errorMessage = json.decode(responseData)['error'] ?? 'Unknown error';
      logger.e('Error: $errorMessage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim pertanyaan: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    logger.e('Error during upload: ${e.toString()}');
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
      setState(() {
        _isLoading = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tanya Komunitas'),
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
                  Column(
                    children: [
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
                              'Upload Foto Tanaman',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_pickedFile != null)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Gambar terpilih',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_pickedFile!.path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => setState(() => _pickedFile = null),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Pertanyaan Anda',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      hintText:
                          'Masukkan pertanyaan yang menunjukkan apa yang salah dengan tanaman anda',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Deskripsi Masalah',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      hintText:
                          'Jelaskan ciri-ciri khususnya seperti perubahan daun, warna, serangga, kerusakan, dll.',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'Kirim',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}