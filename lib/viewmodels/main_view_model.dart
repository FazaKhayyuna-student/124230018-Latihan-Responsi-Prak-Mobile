import 'package:flutter/material.dart';
import 'package:my_anime_archive/models/anime.dart';
import 'package:my_anime_archive/models/user.dart';
import 'package:my_anime_archive/services/api_service.dart';
import 'package:my_anime_archive/services/hive_service.dart';
import 'package:my_anime_archive/services/session_service.dart';

// 1. Menggunakan ChangeNotifier. Ini adalah inti dari 'Provider'
//    Dia bisa 'memberitahu' UI "Hei, ada data berubah, update dirimu!"
class MainViewModel extends ChangeNotifier {
  // 2. Inisialisasi semua service (Manajer) kita
  final ApiService _apiService = ApiService();
  final HiveService _hiveService = HiveService();
  final SessionService _sessionService = SessionService();

  // === Bagian State (Data yang akan dilihat UI) ===

  // State untuk data user yang sedang login
  User? _currentUser;
  User? get currentUser => _currentUser;

  // State untuk daftar top anime dari API
  List<Anime> _topAnimeList = [];
  List<Anime> get topAnimeList => _topAnimeList;

  // State untuk daftar anime favorit dari SharedPreferences
  List<Anime> _favoriteList = [];
  List<Anime> get favoriteList => _favoriteList;

  // State untuk status loading (misal saat login atau panggil API)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // State untuk mengecek sesi (saat app baru dibuka)
  bool _isLoadingSession = true;
  bool get isLoadingSession => _isLoadingSession;

  // === Bagian Fungsi (Logika yang dipanggil UI) ===

  // Panggil ini saat aplikasi pertama kali dibuka
  Future<void> checkLoginSession() async {
    _isLoadingSession = true;

    // Cek ke service session, ada username tersimpan?
    String? loggedInUsername = await _sessionService.getSession();

    if (loggedInUsername != null) {
      // Jika ada, ambil data lengkap user dari Hive
      _currentUser = await _hiveService.getUserByUsername(loggedInUsername);
    } else {
      _currentUser = null;
    }

    _isLoadingSession = false;
    notifyListeners(); // Beritahu UI bahwa pengecekan sesi selesai
  }

  // Fungsi untuk Login
  Future<bool> loginUser(String username, String password) async {
    _isLoading = true;
    notifyListeners(); // Tampilkan loading spinner di UI

    User? user = await _hiveService.loginUser(username, password);

    if (user != null) {
      // Jika login sukses
      _currentUser = user;
      await _sessionService.saveSession(user.username); // Simpan sesi
      _isLoading = false;
      notifyListeners(); // Hilangkan loading, update UI
      return true; // Kirim 'true' ke halaman Login
    }

    // Jika login gagal
    _isLoading = false;
    notifyListeners(); // Hilangkan loading
    return false; // Kirim 'false' ke halaman Login
  }

  // Fungsi untuk Register
  // HAPUS INI:
  // Future<bool> registerUser(String username, String password) async {
  // GANTI DENGAN INI (tambah parameter):
  Future<bool> registerUser(
      String username, String password, String fullName, String nim) async {
    _isLoading = true;
    notifyListeners();

    // HAPUS INI:
    // bool success = await _hiveService.registerUser(username, password);
    // GANTI DENGAN INI (teruskan data baru):
    bool success =
        await _hiveService.registerUser(username, password, fullName, nim);

    _isLoading = false;
    notifyListeners();
    return success; // Kirim 'true'/'false' ke halaman Register
  }

  // Fungsi untuk Logout
  Future<void> logout() async {
    await _sessionService.clearSession(); // Hapus sesi
    _currentUser = null; // Hapus data user
    _favoriteList = []; // Kosongkan favorit saat logout
    notifyListeners(); // Update UI (akan kembali ke halaman login)
  }

  // --- FUNGSI BARU UNTUK UPDATE PROFILE ---
  Future<void> updateUserProfile(String newFullName, String newNim) async {
    // Safety check
    if (_currentUser == null) return;

    // Panggil service untuk menyimpan ke Hive
    await _hiveService.updateUser(_currentUser!, newFullName, newNim);

    // Perbarui state 'currentUser' di ViewModel secara lokal
    _currentUser!.fullName = newFullName;
    _currentUser!.nim = newNim;

    // Beritahu UI untuk refresh
    notifyListeners();
  }

  // Fungsi mengambil Top Anime dari API
  Future<void> fetchTopAnime() async {
    _isLoading = true;
    notifyListeners();
    try {
      _topAnimeList = await _apiService.getTopAnime();
    } catch (e) {
      print(e); // Tangani error
    }
    _isLoading = false;
    notifyListeners();
  }

  // Fungsi mengambil data Favorit dari SharedPreferences
  Future<void> loadFavorites() async {
    // Tidak perlu loading indicator agar tidak mengganggu UI
    _favoriteList = await _sessionService.getFavorites();
    notifyListeners();
  }

  // Fungsi Cek apakah anime favorit (sinkron/langsung)
  // Ini penting untuk icon 'love' di UI
  bool isFavorite(int animeId) {
    return _favoriteList.any((anime) => anime.malId == animeId);
  }

  // Fungsi untuk menambah/menghapus favorit (Toggle)
  Future<void> toggleFavorite(Anime anime) async {
    // Panggil service untuk menyimpan/menghapus
    bool isNowFavorite = await _sessionService.toggleFavorite(anime);

    // Update state di ViewModel ini secara manual agar UI reaktif
    if (isNowFavorite) {
      _favoriteList.add(anime);
    } else {
      _favoriteList.removeWhere((fav) => fav.malId == anime.malId);
    }
    notifyListeners(); // Beritahu UI (icon love) untuk update
  }
}
