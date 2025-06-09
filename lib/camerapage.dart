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
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.black,
            height: 80, 
            padding: const EdgeInsets.only(left: 10, top: 5),
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 25),
              onPressed: _handleBackPress,
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
                        onPressed: _pickFromGallery,
                        iconSize: 32, 
                      ),
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.circle, color: Colors.white, size: 50),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [   
                      IconButton(
                        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
                        onPressed: _confirmPicture,
                        iconSize: 50,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}