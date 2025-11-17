import 'dart:io'; // Dibutuhkan untuk Tipe data 'File'
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Untuk ambil gambar
import 'package:path_provider/path_provider.dart'; // Untuk cari folder
import 'package:path/path.dart' as p; // Untuk gabung path file

// Import services dan models kita
import 'package:my_anime_archive/models/anime.dart';
import 'package:my_anime_archive/models/user.dart';
import 'package:my_anime_archive/services/api_service.dart';
import 'package:my_anime_archive/services/hive_service.dart';
import 'package:my_anime_archive/services/session_service.dart';

class MainViewModel extends ChangeNotifier {
  // 1. Inisialisasi semua service
  final HiveService _hiveService = HiveService();
  final ApiService _apiService = ApiService();
  final SessionService _sessionService = SessionService();

  // 2. Definisi State (Data)
  User? _currentUser;
  bool _isLoading = false;
  bool _isLoadingSession = true;
  List<Anime> _topAnimeList = [];
  List<Anime> _favoriteList = [];

  // --- STATE BARU UNTUK FOTO PROFIL ---
  String? _profileImagePath;

  // 3. Getters (Agar UI hanya bisa 'membaca' data)
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoadingSession => _isLoadingSession;
  List<Anime> get topAnimeList => _topAnimeList;
  List<Anime> get favoriteList => _favoriteList;

  // --- GETTER BARU ---
  String? get profileImagePath => _profileImagePath;

  // Constructor (dijalankan saat pertama kali dibuat)
  MainViewModel() {
    // Kita tidak bisa 'await' di constructor,
    // jadi kita panggil 'checkLoginSession' di 'AuthWrapper'
  }

  // === FUNGSI LOGIKA (Otentikasi & Profil) ===

  Future<void> checkLoginSession() async {
    _isLoadingSession = true; // Mulai loading

    final loggedInUsername = await _sessionService.getSession();

    if (loggedInUsername != null) {
      _currentUser = await _hiveService.getUserByUsername(loggedInUsername);
      // --- TAMBAHKAN INI ---
      // Ambil path foto saat sesi dicek
      _profileImagePath = await _sessionService.getProfileImagePath();
    } else {
      _currentUser = null;
    }

    _isLoadingSession = false; // Selesai loading
    notifyListeners(); // Beritahu UI
  }

  Future<bool> loginUser(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final user = await _hiveService.loginUser(username, password);
    if (user != null) {
      _currentUser = user;
      await _sessionService.saveSession(user.username);
      // Panggil checkLoginSession agar path foto juga ter-load
      await checkLoginSession();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> registerUser(
      String username, String password, String fullName, String nim) async {
    _isLoading = true;
    notifyListeners();

    bool success =
        await _hiveService.registerUser(username, password, fullName, nim);

    _isLoading = false;
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _sessionService.clearSession(); // Ini sudah menghapus path foto juga
    _currentUser = null;
    // --- TAMBAHKAN INI ---
    _profileImagePath = null; // Hapus path foto dari state
    _favoriteList = []; // Kosongkan favorit
    _topAnimeList = []; // Kosongkan list anime
    notifyListeners(); // Update UI (akan kembali ke halaman login)
  }

  Future<void> updateUserProfile(String newFullName, String newNim) async {
    if (_currentUser == null) return;

    // Panggil service untuk menyimpan ke Hive
    await _hiveService.updateUser(_currentUser!, newFullName, newNim);

    // Perbarui state 'currentUser' di ViewModel secara lokal
    _currentUser!.fullName = newFullName;
    _currentUser!.nim = newNim;

    // Beritahu UI untuk refresh
    notifyListeners();
  }

  // --- FUNGSI BARU UNTUK MENGAMBIL FOTO ---
  Future<void> pickAndSaveProfileImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    // 1. Ambil gambar (dari kamera atau galeri)
    final XFile? image = await picker.pickImage(source: source);

    if (image == null) {
      // User membatalkan pemilihan
      return;
    }

    // 2. Dapatkan folder penyimpanan aplikasi
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    // 3. Buat nama file yang unik (misal: 'profile_pic_timestamp.jpg')
    final String fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String permanentPath = p.join(appDirectory.path, fileName);

    // 4. Salin file sementara dari 'image_picker' ke path permanen
    final File imageFile = File(image.path);
    await imageFile.copy(permanentPath);

    // 5. Simpan path permanen ke SharedPreferences
    await _sessionService.saveProfileImagePath(permanentPath);

    // 6. Update state di ViewModel
    _profileImagePath = permanentPath;
    notifyListeners(); // Beritahu UI untuk update foto
  }

  // === FUNGSI LOGIKA (Anime & Favorit) ===

  Future<void> fetchTopAnime() async {
    _isLoading = true;
    notifyListeners();
    try {
      _topAnimeList = await _apiService.getTopAnime();
    } catch (e) {
      print(e); // Handle error
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFavorites() async {
    _favoriteList = await _sessionService.getFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(Anime anime) async {
    // Toggle di SharedPreferences
    await _sessionService.toggleFavorite(anime);

    // Update state favorit secara lokal
    if (isFavorite(anime.malId)) {
      _favoriteList.removeWhere((fav) => fav.malId == anime.malId);
    } else {
      _favoriteList.add(anime);
    }
    notifyListeners(); // Update UI (terutama icon love)
  }

  bool isFavorite(int animeId) {
    return _favoriteList.any((anime) => anime.malId == animeId);
  }
}
