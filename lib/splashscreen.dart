import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:frontend/home.dart';
import 'package:frontend/signinpage.dart'; 
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const SplashScreen({super.key, required this.cameras});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
      () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('accessToken');

        if (token != null && token.isNotEmpty) {
          // Jika token ada, arahkan ke HomeScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => HomeScreen(
                cameras: widget.cameras,
              ),
            ),
          );
        } else {
          // Jika tidak ada token, arahkan ke SignInPage
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => SignInPage(
                cameras: widget.cameras,
              ),
            ),
          );
        }
      },
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