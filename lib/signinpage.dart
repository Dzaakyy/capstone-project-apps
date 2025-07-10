import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/home.dart';
import 'package:camera/camera.dart';
import 'package:frontend/registerpage.dart';

class SignInPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const SignInPage({super.key, required this.cameras});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Menambahkan state untuk loading
  bool _isLoading = false;

  Future<void> login() async {
    // Validasi input kosong di awal
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan password tidak boleh kosong"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true; // Mulai loading
    });

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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // Ekstrak token dari header cookie
        final rawCookie = response.headers['set-cookie'];
        String token = '';
        if (rawCookie != null) {
          int index = rawCookie.indexOf('accessToken=');
          if (index != -1) {
            token = rawCookie.substring(index + 'accessToken='.length).split(';')[0];
          }
        }
        await prefs.setString('accessToken', token);

        // Decode token untuk mendapatkan role
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = jsonDecode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );
          
          final String roleName = payload['roleName'] ?? '';
          
          // --- PENGECEKAN ROLE DIMULAI DI SINI ---
          // Gunakan .toLowerCase() agar tidak terpengaruh huruf besar/kecil (misal: 'Petani' atau 'petani')
          if (roleName.toLowerCase() != 'petani') { 
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Akses ditolak. Halaman ini khusus untuk petani."),
                  backgroundColor: Colors.red,
                ),
              );
            }
            // Hentikan proses jika bukan petani
            setState(() { _isLoading = false; });
            return; 
          }
          // --- AKHIR PENGECEKAN ROLE ---

          // Simpan data jika role sesuai
          await prefs.setInt('idUser', payload['userId']);
          await prefs.setString('namaUser', payload['username']);
          await prefs.setString('roleName', roleName);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Login Berhasil!"), backgroundColor: Colors.green),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(cameras: widget.cameras)),
            );
          }
        } else {
           throw Exception('Format token tidak valid');
        }
      } else {
        throw Exception(dataLogin['msg'] ?? 'Login Gagal');
      }
    } catch (exc) {
      if (kDebugMode) {
        print("Error: $exc");
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi kesalahan: ${exc.toString().replaceFirst("Exception: ", "")}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false; // Selesai loading
        });
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
            './lib/assets/signin.png', // Pastikan path asset benar
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Column(
              children: [
                const Expanded(flex: 1, child: SizedBox(height: 10)),
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
                              decoration: InputDecoration(
                                label: const Text('Username'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            const SizedBox(height: 25.0),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                label: const Text('Password'),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                            const SizedBox(height: 25.0),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : login, // Nonaktifkan tombol saat loading
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade300,
                                  foregroundColor: Colors.white,
                                ),
                                child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Sign In', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignUpPage(cameras: widget.cameras)),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'Belum punya akun? ',
                                  style: const TextStyle(color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: 'Daftar disini',
                                      style: TextStyle(
                                        color: Colors.blue.shade300,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
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