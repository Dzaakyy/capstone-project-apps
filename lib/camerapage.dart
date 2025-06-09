import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  void _confirmPicture() {
    if (_capturedImage != null) {
      Navigator.pop(context, _capturedImage!.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        children: [
          _capturedImage == null
              ? SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: CameraPreview(_controller),
                )
              : SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Image.file(File(_capturedImage!.path), fit: BoxFit.cover),
                ),

          
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: _capturedImage == null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround, 
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_library, color: Colors.white),
                        onPressed: _pickFromGallery,
                        iconSize: 40,
                      ),
                      GestureDetector(
                        onTap: _takePicture,
                        child: const Icon(Icons.circle, color: Colors.white, size: 60),
                      ),
                      const SizedBox(width: 40), 
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _retakePicture,
                        iconSize: 40,
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.white),
                        onPressed: _confirmPicture,
                        iconSize: 40,
                      ),
                    ],
                  ),
          ),

          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
