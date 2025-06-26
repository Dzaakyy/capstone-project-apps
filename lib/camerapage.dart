import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/diagnosiscore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:frontend/diagnosispage.dart';
import 'package:logger/logger.dart';

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
  final logger = Logger();

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
            logger.i('User denied camera access.');
            break;
          default:
            logger.i('Error: ${e.code}\n${e.description}');
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
        File(_capturedImage!.path),
      );

      if (diagnosisResult.error == 'Bukan daun mangga') {
        _showNotMangoAlert();
      } else if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DiagnosisPage(
              diagnosisResult: diagnosisResult,
              cameras: widget.cameras,
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

  void _showNotMangoAlert() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      size: 40,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Not a Mango Leaf',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The image you provided doesn\'t appear to be a mango leaf. Please try again with a clear image of a mango leaf.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _retakePicture();
                      },
                      child: const Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

void _showErrorSnackBar(String message) {
  if (mounted) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600], size: 30),
                    const SizedBox(width: 10),
                    Text(
                      'Error',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  message.contains('Penyakit tidak ditemukan di database')
                      ? 'Maaf, penyakit pada daun ini tidak ditemukan dalam database. Silakan coba dengan gambar lain atau tanyakan ke komunitas.'
                      : message,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Tutup',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.circle,
                                color: _isProcessingDiagnosis ? Colors.grey : Colors.white,
                                size: 50,
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
                              color: _isProcessingDiagnosis ? Colors.grey : Colors.white,
                            ),
                            onPressed: _isProcessingDiagnosis ? null : _confirmPicture,
                            iconSize: 50,
                          ),
                        ],
                      ),
              ),
            ],
          ),
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