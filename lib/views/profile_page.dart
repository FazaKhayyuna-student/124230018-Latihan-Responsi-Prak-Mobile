import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_anime_archive/viewmodels/main_view_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controller tetap dibutuhkan, tapi untuk modal
  late TextEditingController _fullNameController;
  late TextEditingController _nimController;

  @override
  void initState() {
    super.initState();
    final user =
        Provider.of<MainViewModel>(context, listen: false).currentUser!;
    _fullNameController = TextEditingController(text: user.fullName);
    _nimController = TextEditingController(text: user.nim);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nimController.dispose();
    super.dispose();
  }

  // --- FUNGSI-FUNGSI LOGIKA ---

  void _handleLogout(BuildContext context) {
    Provider.of<MainViewModel>(context, listen: false).logout();
  }

  // Fungsi ini dipanggil oleh tombol 'Simpan' di dalam modal
  void _handleUpdateProfile(BuildContext modalContext) {
    final newName = _fullNameController.text;
    final newNim = _nimController.text;

    if (newName.isEmpty || newNim.isEmpty) {
      _showMessage("Nama dan NIM tidak boleh kosong!", isError: true);
      return;
    }

    Provider.of<MainViewModel>(context, listen: false)
        .updateUserProfile(newName, newNim);

    _showMessage("Profile berhasil di-update!", isError: false);

    // Tutup modal setelah update
    Navigator.pop(modalContext);
  }

  // Helper pesan (Snackbar)
  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // --- FUNGSI UNTUK TAMPILAN (UI) ---

  // FUNGSI BARU: Untuk menampilkan modal pop-up
  void _showEditProfileModal(BuildContext context) {
    // Pastikan controller berisi data terbaru sebelum modal tampil
    final user =
        Provider.of<MainViewModel>(context, listen: false).currentUser!;
    _fullNameController.text = user.fullName;
    _nimController.text = user.nim;

    showModalBottomSheet(
      context: context,
      // Penting agar modal tidak tertutup keyboard
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return Padding(
          // Padding ini akan 'mendorong' modal ke atas keyboard
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(modalContext).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Agar tinggi modal secukupnya
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Profile",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: "Nama Lengkap",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.badge),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nimController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "NIM",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.school),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _handleUpdateProfile(modalContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Simpan Perubahan"),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Tampilan utama halaman (build)
  @override
  Widget build(BuildContext context) {
    // 'watch' akan otomatis update UI saat data user berubah
    final user = context.watch<MainViewModel>().currentUser!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Profile",
          style: TextStyle(
            color: Colors.grey[900],
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
            tooltip: "Edit Profile",
            onPressed: () => _showEditProfileModal(context),
          ),
        ],
      ),
      // 2. KEMBALIKAN BODY JADI 'DISPLAY-ONLY' (LEBIH BERSIH)
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.purple,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Tampilan info statis
            _buildProfileInfo("Nama Lengkap", user.fullName),
            _buildProfileInfo("NIM", user.nim),
            _buildProfileInfo("Username", user.username), // Username tetap

            const Spacer(), // Dorong tombol logout ke bawah

            // 3. HAPUS TOMBOL UPDATE DARI SINI

            // Tombol Logout (tetap)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _handleLogout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk menampilkan info (tidak berubah)
  Widget _buildProfileInfo(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ),
    );
  }
}
