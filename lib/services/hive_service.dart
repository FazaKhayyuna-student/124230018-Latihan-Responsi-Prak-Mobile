import 'package:hive/hive.dart';
import 'package:my_anime_archive/models/user.dart'; // Import model User kita

class HiveService {
  // Ini adalah nama "kotak" di database Hive tempat kita menyimpan user
  final String _userBoxName = 'userBox';

  // Fungsi internal untuk membuka kotak user
  Future<Box<User>> _getUserBox() async {
    // Kita akan mendaftarkan 'Adapter' di file main.dart nanti
    // Jadi di sini kita tinggal buka kotaknya
    return await Hive.openBox<User>(_userBoxName);
  }

  // --- FUNGSI UNTUK REGISTER ---
  // HAPUS INI:
  // Future<bool> registerUser(String username, String password) async {
  // GANTI DENGAN INI (tambah parameter):
  Future<bool> registerUser(
      String username, String password, String fullName, String nim) async {
    final box = await _getUserBox();

    // Cek dulu apakah username sudah ada yang pakai
    // 'any' akan cek satu per satu user di dalam box
    final userExists = box.values.any((user) => user.username == username);

    if (userExists) {
      return false; // Gagal register, username sudah dipakai
    }

    // Jika aman, buat objek User baru
    // HAPUS INI:
    // final newUser = User(
    //   username: username,
    //   password: password
    // );

    // GANTI DENGAN INI (masukkan data baru):
    final newUser = User(
      username: username,
      password: password,
      fullName: fullName,
      nim: nim,
    );

    // Simpan user baru ke dalam box
    await box.add(newUser);
    return true; // Berhasil register
  }

  // --- FUNGSI UNTUK LOGIN ---
  Future<User?> loginUser(String username, String password) async {
    final box = await _getUserBox();

    // Cari user berdasarkan username
    try {
      // 'firstWhere' akan mencari user pertama yang username-nya cocok
      final user = box.values.firstWhere((user) => user.username == username);

      // Jika user ditemukan, cek password-nya
      if (user.password == password) {
        return user; // Sukses! Kembalikan data user
      }

      // Jika password salah
      return null;
    } catch (e) {
      // Ini terjadi jika 'firstWhere' tidak menemukan user-nya
      return null;
    }
  }

  // --- FUNGSI BARU UNTUK UPDATE PROFILE ---
  Future<void> updateUser(
      User userToUpdate, String newFullName, String newNim) async {
    // Karena 'userToUpdate' adalah HiveObject, kita bisa langsung ubah
    userToUpdate.fullName = newFullName;
    userToUpdate.nim = newNim;

    // Panggil '.save()' untuk menyimpan perubahan ke database
    await userToUpdate.save();
  }

  // --- FUNGSI UNTUK HALAMAN PROFIL ---
  Future<User?> getUserByUsername(String username) async {
    final box = await _getUserBox();
    try {
      return box.values.firstWhere((user) => user.username == username);
    } catch (e) {
      // User tidak ditemukan
      return null;
    }
  }
}
