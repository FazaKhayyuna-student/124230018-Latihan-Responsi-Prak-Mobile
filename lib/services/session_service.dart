import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_anime_archive/models/anime.dart'; // Model Anime

class SessionService {
  final String _sessionKey = 'user_session'; // Untuk menyimpan username
  final String _favoritesKey = 'user_favorites'; // Untuk menyimpan list anime favorit

  // === Bagian Session Login ===

  // Simpan sesi login (username)
  Future<void> saveSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, username);
  }

  // Ambil sesi login (username)
  Future<String?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  // Hapus sesi login (logout)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  // === Bagian Anime Favorit ===

  // Ambil daftar favorit
  Future<List<Anime>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    // Ambil list of string JSON
    final List<String> favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
    
    // Ubah kembali dari string JSON ke objek Anime
    return favoritesJson.map((jsonString) {
      // Kita pakai json.decode di sini (dari 'dart:convert')
      return Anime.fromJsonString(json.decode(jsonString));
    }).toList();
  }

  // Cek apakah anime sudah ada di favorit (untuk icon love)
  Future<bool> isFavorite(int animeId) async {
    final favorites = await getFavorites();
    return favorites.any((anime) => anime.malId == animeId);
  }

  // Tambah/Hapus dari favorit (toggle)
  Future<bool> toggleFavorite(Anime anime) async {
    final prefs = await SharedPreferences.getInstance();
    List<Anime> favorites = await getFavorites();
    bool isCurrentlyFavorite = false; // Status baru setelah di-toggle

    if (favorites.any((fav) => fav.malId == anime.malId)) {
      // Jika sudah ada, hapus
      favorites.removeWhere((fav) => fav.malId == anime.malId);
      isCurrentlyFavorite = false;
    } else {
      // Jika belum ada, tambahkan
      favorites.add(anime);
      isCurrentlyFavorite = true;
    }

    // Ubah list objek Anime menjadi list string JSON
    List<String> favoritesJson = favorites.map((fav) {
      // Kita pakai json.encode di sini (dari 'dart:convert')
      return json.encode(fav.toJson()); // Gunakan method toJson() dari model Anime
    }).toList();

    // Simpan kembali ke Shared Preferences
    await prefs.setStringList(_favoritesKey, favoritesJson);
    return isCurrentlyFavorite; // Kembalikan status favorit yang baru
  }
}