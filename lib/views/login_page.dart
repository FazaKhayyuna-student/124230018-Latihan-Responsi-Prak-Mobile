import 'package:flutter/material.dart';
import 'package:my_anime_archive/viewmodels/main_view_model.dart';
import 'package:provider/provider.dart';
import 'package:my_anime_archive/views/register_page.dart'; // Import halaman register

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 1. Controller untuk mengambil teks dari form
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // 2. Fungsi yang dipanggil saat tombol login ditekan
  void _handleLogin() async {
    // Ambil data dari controller
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      // Tampilkan error jika ada yang kosong
      _showError("Username dan password tidak boleh kosong!");
      return;
    }

    // Panggil fungsi login dari ViewModel
    // 'listen: false' wajib di dalam fungsi/event
    final viewModel = Provider.of<MainViewModel>(context, listen: false);

    // Panggil fungsi login
    bool success = await viewModel.loginUser(username, password);

    // 3. Jika login GAGAL (karena 'success' == false)
    if (!success && mounted) {
      _showError("Username atau password salah!");
    }

    // 4. Jika login BERHASIL (success == true)
    //    Kita TIDAK PERLU 'Navigator.push'
    //    AuthWrapper di main.dart akan otomatis mendeteksi
    //    perubahan 'currentUser' dan memindahkan halaman
  }

  // Fungsi helper untuk menampilkan error
  void _showError(String message) {
    if (!mounted) return; // Pastikan widget masih ada
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    // Bersihkan controller
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 5. Kita 'tonton' (watch) state 'isLoading' dari ViewModel
    //    Ini akan membuat UI-nya disable tombol saat loading
    final isLoading = context.watch<MainViewModel>().isLoading;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "MyAnimeArchive",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 40),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          labelText: "Username",
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        enabled: !isLoading,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  "Login",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterPage(),
                                  ),
                                );
                              },
                        child: const Text("Belum punya akun? Daftar di sini"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
