import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  String? _prediction;
  double? _confidence;
  final picker = ImagePicker();
  final String baseUrl = 'http://10.0.2.2:3000'; 
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _prediction = null; 
        _confidence = null;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _prediction = 'Processing...';
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/prediksi/create'),
      );
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);
        
        if (jsonResponse['error'] != null) {
          setState(() {
            _prediction = jsonResponse['error'];
            _confidence = null;
          });
        } else {
          setState(() {
            _prediction = jsonResponse['prediction']?.toString();
            _confidence = jsonResponse['confidence']?.toDouble();
          });
        }
      } else {
        setState(() {
          _prediction = 'Failed to process prediction (Status: ${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _prediction = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mango Leaf Disease Detection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 16),
            _image != null
                ? Center(child: Image.file(_image!, height: 150))
                : const Center(child: Text('No image selected')),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _uploadImage,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Predict'),
              ),
            ),
            const SizedBox(height: 16),
            if (_prediction != null) ...[
              const Text('Result:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Prediction: $_prediction',
                style: TextStyle(
                  color: _confidence == null ? Colors.red : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_confidence != null) 
                Text('Akurasi: ${(_confidence! * 100).toStringAsFixed(2)}%'),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}