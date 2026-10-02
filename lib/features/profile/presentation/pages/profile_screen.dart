import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:frontend/features/profile/presentation/bloc/profile_event.dart';
import 'package:frontend/features/profile/presentation/bloc/profile_state.dart';
import 'package:frontend/features/auth/presentation/pages/signin_screen.dart';
import 'package:camera/camera.dart';

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

  String? originalNama;
  String? originalUsername;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    
    // Fetch profile on init
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Panjang password minimal 5 karakter"),
          backgroundColor: Colors.red,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profil berhasil diperbarui!'),
                backgroundColor: Colors.green),
          );
          setState(() {
            _isEditing = false;
            _hasChanges = false;
            _passwordController.clear();
          });
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red),
          );
        } else if (state is ProfileLogoutSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => SignInPage(cameras: widget.cameras)),
            (route) => false,
          );
        } else if (state is ProfileLoaded) {
           originalNama = state.profileData['user']['nama'];
           originalUsername = state.profileData['user']['username'];
           
           if (!_isEditing && _namaController.text.isEmpty) {
             _namaController.text = originalNama ?? '';
             _usernameController.text = originalUsername ?? '';
           }
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading || state is ProfileInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ProfileError && originalNama == null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: _logout,
                        child: const Text('Kembali ke Login')),
                  ],
                ),
              ),
            ),
          );
        }

        String nama = originalNama ?? '';
        String username = originalUsername ?? '';
        String role = 'Tidak ada role';
        
        if (state is ProfileLoaded) {
          nama = state.profileData['user']['nama'] ?? '';
          username = state.profileData['user']['username'] ?? '';
          role = state.profileData['user']['role']?['nama'] ?? 'Tidak ada role';
        } else if (state is ProfileUpdateSuccess) {
          nama = state.profileData['user']['nama'] ?? '';
          username = state.profileData['user']['username'] ?? '';
          role = state.profileData['user']['role']?['nama'] ?? 'Tidak ada role';
        }

        return Scaffold(
          body: Stack(
            children: [
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.blue.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                child: Text(_isEditing ? 'Edit Profil' : 'Profil Saya',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
              ),
              if (!_isEditing)
                Positioned(
                  top: 40,
                  right: 10,
                  child: IconButton(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Logout',
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 120.0),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: [
                    if (_isEditing)
                      _buildEditView()
                    else
                      _buildDisplayView(nama, username, role),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDisplayView(String nama, String username, String role) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 55,
            backgroundColor: Colors.blue[50],
            child: Icon(Icons.person, size: 70, color: Colors.blue[800]),
          ),
        ),
        const SizedBox(height: 16),
        Text(nama,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(username,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.black54)),
        const SizedBox(height: 24),
        Card(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading:
                const Icon(Icons.verified_user_outlined, color: Colors.blue),
            title: const Text('Peran Pengguna',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(role, style: const TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 5,
          ),
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profil'),
          onPressed: () {
             setState(() {
               _isEditing = true;
               _namaController.text = originalNama ?? '';
               _usernameController.text = originalUsername ?? '';
             });
          },
        ),
      ],
    );
  }

  Widget _buildEditView() {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Edit Profil",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Nama tidak boleh kosong'
                    : null,
                onChanged: (_) => _checkForChanges(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.alternate_email),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Username tidak boleh kosong'
                    : null,
                onChanged: (_) => _checkForChanges(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password Baru (Opsional)',
                  hintText: 'Isi untuk mengganti password (min 5 karakter)',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                obscureText: true,
                onChanged: (_) => _checkForChanges(),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      onPressed: () => setState(() {
                        _isEditing = false;
                        _namaController.text = originalNama ?? '';
                        _usernameController.text = originalUsername ?? '';
                        _passwordController.clear();
                        _hasChanges = false;
                      }),
                      child: const Text('Batal',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        backgroundColor: _hasChanges ? Colors.blue : Colors.grey,
                      ),
                      onPressed: _hasChanges ? _updateProfile : null,
                      child: const Text('Simpan',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 65);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
