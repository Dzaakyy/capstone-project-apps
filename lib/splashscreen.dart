import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/home.dart';

class SplashScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const SplashScreen({super.key, required this.cameras});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
    @override
  void initState(){
    super.initState();
    Timer(
      const Duration(seconds: 3),
      (() => Navigator.of(context).pushReplacement
      (MaterialPageRoute(builder: (BuildContext context) => HomeScreen(cameras: widget.cameras)))
      )
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('./lib/assets/gambar1.jpg'),
      ),
    );
  }
}
