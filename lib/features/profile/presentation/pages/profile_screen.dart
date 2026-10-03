import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:frontend/features/profile/presentation/bloc/profile_event.dart';
import 'package:frontend/features/profile/presentation/bloc/profile_state.dart';
import 'package:frontend/features/auth/presentation/pages/signin_screen.dart';
import 'package:camera/camera.dart';
import 'package:frontend/core/utils/snackbar_util.dart';

class ProfileScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ProfileScreen({super.key, required this.cameras});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  bool _isPasswordVisible = false;

  String? originalNama;
  String? originalUsername;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    
    context.read<ProfileBloc>().add(ProfileFetchRequested());
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _checkForChanges() {
    setState(() {
      _hasChanges = _namaController.text != originalNama ||
          _usernameController.text != originalUsername ||
          _passwordController.text.isNotEmpty;
    });
  }

  void _updateProfile() {
    if (!_formKey.currentState!.validate() || !_hasChanges) return;

    if (_passwordController.text.isNotEmpty && _passwordController.text.length < 5) {
      SnackbarUtil.showWarning(context, "Panjang password minimal 5 karakter");
      return;
    }

    context.read<ProfileBloc>().add(ProfileUpdateRequested(
      nama: _namaController.text,
      username: _usernameController.text,
      password: _passwordController.text.isEmpty ? null : _passwordController.text,
    ));
  }

  void _logout() {
    context.read<ProfileBloc>().add(ProfileLogoutRequested());
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blue.shade400),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _isEditing ? Colors.white : Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: _isEditing ? Colors.grey.shade300 : Colors.transparent,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          SnackbarUtil.showSuccess(context, "Profil berhasil diperbarui!");
          setState(() {
            _isEditing = false;
            _hasChanges = false;
            _passwordController.clear();
          });
        } else if (state is ProfileError) {
          SnackbarUtil.showError(context, state.message);
        } else if (state is ProfileLogoutSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => SignInPage(cameras: widget.cameras)),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading && !(_hasChanges && _isEditing)) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Colors.blue),
            ),
          );
        }

        if (state is ProfileLoaded || state is ProfileUpdateSuccess) {
          if (state is ProfileLoaded) {
            originalNama = state.profileData['user']['nama'];
            originalUsername = state.profileData['user']['username'];
            
            if (!_isEditing && _namaController.text.isEmpty) {
              _namaController.text = originalNama ?? '';
              _usernameController.text = originalUsername ?? '';
            }
          }

          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              backgroundColor: Colors.blue.shade600,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Profil Saya',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                if (!_isEditing)
                  IconButton(
                    icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                        _namaController.text = originalNama ?? '';
                        _usernameController.text = originalUsername ?? '';
                      });
                    },
                  ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // Header section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade200.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    padding: const EdgeInsets.only(bottom: 40, top: 20),
                    child: Column(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.blue.shade100, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: 60,
                            color: Colors.blue.shade200,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          originalNama ?? 'Pengguna',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${originalUsername ?? ''}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue.shade100,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Form Section
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Informasi Pribadi",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          TextFormField(
                            controller: _namaController,
                            enabled: _isEditing,
                            onChanged: (_) => _checkForChanges(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            decoration: _buildInputDecoration('Nama Lengkap', Icons.badge_outlined),
                          ),
                          const SizedBox(height: 20),
                          
                          TextFormField(
                            controller: _usernameController,
                            enabled: _isEditing,
                            onChanged: (_) => _checkForChanges(),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            decoration: _buildInputDecoration('Username', Icons.person_outline),
                          ),
                          const SizedBox(height: 20),
                          
                          if (_isEditing)
                            TextFormField(
                              controller: _passwordController,
                              enabled: true,
                              obscureText: !_isPasswordVisible,
                              onChanged: (_) => _checkForChanges(),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              decoration: _buildInputDecoration(
                                'Password Baru (Opsional)', 
                                Icons.lock_outline,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                    color: Colors.grey.shade500,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),

                          const SizedBox(height: 40),

                          if (_isEditing) ...[
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: _hasChanges ? _updateProfile : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.blue.shade200,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: _hasChanges ? 4 : 0,
                                ),
                                child: const Text(
                                  'Simpan Perubahan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _isEditing = false;
                                    _namaController.text = originalNama ?? '';
                                    _usernameController.text = originalUsername ?? '';
                                    _passwordController.clear();
                                    _hasChanges = false;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey.shade700,
                                  side: BorderSide(color: Colors.grey.shade300, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton.icon(
                                onPressed: _logout,
                                icon: const Icon(Icons.logout_rounded, size: 22),
                                label: const Text(
                                  'Keluar Akun',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade50,
                                  foregroundColor: Colors.red.shade600,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: Colors.red.shade200),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Text('Terjadi kesalahan yang tidak terduga.'),
          ),
        );
      },
    );
  }
}
