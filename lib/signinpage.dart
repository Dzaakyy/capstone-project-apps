import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/home.dart';
import 'package:camera/camera.dart';

class SignInPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const SignInPage({super.key, required this.cameras});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> login() async {
    String urlLogin = "http://10.0.2.2:3000/api/user/login";
    try {
      var response = await http.post(
        Uri.parse(urlLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": _usernameController.text,
          "password": _passwordController.text,
        }),
      );

      if (kDebugMode) {
        print("Response: ${response.body}");
      }

      var dataLogin = jsonDecode(response.body);
      if (response.statusCode == 200 && dataLogin['msg'] == 'Login Berhasil') {
        // Simpan token ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'accessToken',
            response.headers['set-cookie']?.split('accessToken=')[1].split(';')[0] ??
                '');

        // Decode JWT untuk mendapatkan data pengguna
        final token = prefs.getString('accessToken');
        final parts = token?.split('.');
        if (parts != null && parts.length == 3) {
          final payload = jsonDecode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );
          await prefs.setInt('idUser', payload['userId']);
          await prefs.setString('namaUser', payload['username']);
          await prefs.setString('roleName', payload['roleName']);
        }

        // Tampilkan pesan sukses jika widget masih mounted
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Login Berhasil!"),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }

        // Navigasi ke HomeScreen jika widget masih mounted
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                cameras: widget.cameras, // Hanya teruskan cameras
              ),
            ),
          );
        }
      } else {
        if (kDebugMode) {
          print("Login gagal: ${dataLogin['msg']}");
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Login Gagal: ${dataLogin['msg']}"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (exc) {
      if (kDebugMode) {
        print("Error: $exc");
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Terjadi kesalahan. Coba lagi nanti."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Image.asset(
            './lib/assets/signin.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Column(
              children: [
                const Expanded(
                  flex: 1,
                  child: SizedBox(height: 10),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40.0),
                        topRight: Radius.circular(40.0),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Selamat Datang',
                              style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.w900,
                                color: Colors.blue.shade300,
                              ),
                            ),
                            const SizedBox(height: 40.0),
                            TextFormField(
                              controller: _usernameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Username';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Username'),
                                hintText: 'Enter Username',
                                hintStyle: const TextStyle(color: Colors.black26),
                                border: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25.0),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Password';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                label: const Text('Password'),
                                hintText: 'Enter Password',
                                hintStyle: const TextStyle(color: Colors.black26),
                                border: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25.0),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_usernameController.text.isEmpty ||
                                      _passwordController.text.isEmpty) {
                                    if (kDebugMode) {
                                      print(
                                          "Username dan password tidak boleh kosong");
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Username dan password tidak boleh kosong"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  login();
                                },
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}