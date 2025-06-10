import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/diagnosiscore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'diagnosispage.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraPage({super.key, required this.cameras});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  bool _isProcessingDiagnosis = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print('User denied camera access.');
            break;
          default:
            print('Error: ${e.code}\n${e.description}');
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _takePicture() async {
    if (!_controller.value.isTakingPicture) {
      final XFile file = await _controller.takePicture();
      setState(() {
        _capturedImage = file;
      });
    }
  }

  void _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _capturedImage = image;
      });
    }
  }

  void _retakePicture() {
    setState(() {
      _capturedImage = null;
    });
  }

  void _confirmPicture() async {
    if (_capturedImage == null) {
      _showErrorSnackBar('No image selected');
      return;
    }

    setState(() {
      _isProcessingDiagnosis = true;
    });

    try {
      final diagnosisResult = await DiagnosisService.performDiagnosis(
        File(_capturedImage!.path)
      );
      
      if (mounted) {
        // Navigate to DiagnosisPage with the result AND cameras parameter
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DiagnosisPage(
              diagnosisResult: diagnosisResult,
              cameras: widget.cameras, // Pass cameras parameter
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Diagnosis failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingDiagnosis = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _handleBackPress() {
    if (_capturedImage != null) {
      _retakePicture(); 
    } else {
      Navigator.pop(context); 
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: Colors.black,
                height: 80, 
                padding: const EdgeInsets.only(left: 10, top: 5),
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 25),
                  onPressed: _isProcessingDiagnosis ? null : _handleBackPress,
                ),
              ),
              
              // Camera/Image Preview
              Expanded(
                flex: 9, 
                child: Container(
                  color: Colors.black,
                  width: double.infinity, 
                  child: _capturedImage == null
                      ? CameraPreview(_controller)
                      : Image.file(
                          File(_capturedImage!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                ),
              ),
              
              // Bottom Controls
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.black,
                child: _capturedImage == null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.photo_library, color: Colors.white),
                            onPressed: _isProcessingDiagnosis ? null : _pickFromGallery,
                            iconSize: 32, 
                          ),
                          GestureDetector(
                            onTap: _isProcessingDiagnosis ? null : _takePicture,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _isProcessingDiagnosis ? Colors.grey : Colors.white, 
                                  width: 2
                                ),
                              ),
                              child: Icon(
                                Icons.circle, 
                                color: _isProcessingDiagnosis ? Colors.grey : Colors.white, 
                                size: 50
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [   
                          IconButton(
                            icon: Icon(
                              Icons.check_circle_rounded, 
                              color: _isProcessingDiagnosis ? Colors.grey : Colors.white
                            ),
                            onPressed: _isProcessingDiagnosis ? null : _confirmPicture,
                            iconSize: 50,
                          ),
                        ],
                      ),
              ),
            ],
          ),
          
          // Loading Overlay
          if (_isProcessingDiagnosis)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing image...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please wait while we diagnose the leaf',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

