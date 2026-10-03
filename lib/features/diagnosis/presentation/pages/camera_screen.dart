import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:frontend/features/diagnosis/presentation/bloc/diagnosis_bloc.dart';
import 'package:frontend/features/diagnosis/presentation/bloc/diagnosis_event.dart';
import 'package:frontend/features/diagnosis/presentation/bloc/diagnosis_state.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import 'package:frontend/features/diagnosis/presentation/pages/diagnosis_screen.dart';
import 'package:logger/logger.dart';
import 'package:frontend/core/utils/snackbar_util.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraPage({super.key, required this.cameras});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  bool _isCameraInitialized = false;
  final ImagePicker _picker = ImagePicker();
  XFile? _capturedImage;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.max, enableAudio: false);
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

  void _confirmPicture() {
    if (_capturedImage == null) {
      SnackbarUtil.showError(context, 'No image selected');
      return;
    }

    context.read<DiagnosisBloc>().add(DiagnosisRequested(File(_capturedImage!.path)));
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
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_rounded,
                      size: 48,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Not a Mango Leaf',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The image you provided doesn\'t appear to be a mango leaf. Please try again with a clear image.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
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
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        ),
      );
    }

    return BlocConsumer<DiagnosisBloc, DiagnosisState>(
      listener: (context, state) {
        if (state is DiagnosisSuccess) {
          if (state.result.error == 'Bukan daun mangga') {
            _showNotMangoAlert();
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DiagnosisPage(
                  diagnosisResult: state.result,
                  cameras: widget.cameras,
                ),
              ),
            );
          }
        } else if (state is DiagnosisError) {
          if (state.message.contains('Bukan daun mangga')) {
            _showNotMangoAlert();
          } else {
            final msg = state.message.contains('Penyakit tidak ditemukan')
                      ? 'Maaf, penyakit pada daun ini tidak ditemukan. Silakan coba dengan gambar lain.'
                      : state.message;
            SnackbarUtil.showError(context, msg);
          }
        }
      },
      builder: (context, state) {
        final _isProcessingDiagnosis = state is DiagnosisLoading;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: _capturedImage == null
                    ? CameraPreview(_controller)
                    : Image.file(
                        File(_capturedImage!.path),
                        fit: BoxFit.cover,
                      ),
              ),
              
              // Top Overlay for Back Button
              Positioned(
                top: 50,
                left: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                        onPressed: _isProcessingDiagnosis ? null : _handleBackPress,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Overlay for Controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 50, top: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: _capturedImage == null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                                    onPressed: _isProcessingDiagnosis ? null : _pickFromGallery,
                                    iconSize: 28,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _isProcessingDiagnosis ? null : _takePicture,
                              child: Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    height: 65,
                                    width: 65,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 60), // Balance the layout
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: InkWell(
                                  onTap: _isProcessingDiagnosis ? null : _confirmPicture,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 28),
                                        SizedBox(width: 12),
                                        Text(
                                          'Confirm Image',
                                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              if (_isProcessingDiagnosis)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Analyzing Plant',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Please wait a moment...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    );
  }
}
