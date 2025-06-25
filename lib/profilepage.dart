import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/signinpage.dart';
import 'package:camera/camera.dart';

class ProfileScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ProfileScreen({super.key, required this.cameras});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? nama;
  String? username;
  String? role;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = 'Token tidak ditemukan. Silakan login kembali.';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/api/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print("Profile Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] == 'Profile User') {
          setState(() {
            nama = data['user']['nama'];
            username = data['user']['username'];
            role = data['user']['role']?['nama'] ?? 'Tidak ada role';
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = 'Gagal memuat profil: ${data['message']}';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Gagal memuat profil: ${response.statusCode}';
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
      setState(() {
        isLoading = false;
        errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  Future<void> _logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('idUser');
      await prefs.remove('namaUser');
      await prefs.remove('roleName');

      // Kirim permintaan logout ke backend
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/api/user/logout'),
        headers: {
          'Authorization': 'Bearer ${prefs.getString('accessToken')}',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print("Logout Response: ${response.body}");
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignInPage(cameras: widget.cameras),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print("Logout Error: $e");
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : errorMessage != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _logout,
                        child: const Text('Kembali ke Login'),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person,
                          size: 100,
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          nama ?? 'Nama Tidak Tersedia',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Username: $username',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Role: $role',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}