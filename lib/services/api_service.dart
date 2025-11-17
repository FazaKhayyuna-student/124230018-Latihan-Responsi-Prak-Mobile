import 'package:dio/dio.dart';
import 'package:my_anime_archive/models/anime.dart'; // Import model Anime kita

class ApiService {
  // 1. Buat satu 'instance' Dio untuk digunakan di kelas ini
  final Dio _dio = Dio();
  
  // 2. Tentukan URL dasar dari API Jikan
  final String _baseUrl = 'https://api.jikan.moe/v4';

  // 3. Buat fungsi untuk mengambil daftar Top Anime
  //    Fungsi ini akan mengembalikan 'List<Anime>' di masa depan (Future)
  Future<List<Anime>> getTopAnime() async {
    try {
      // 4. Panggil endpoint '/top/anime'
      final response = await _dio.get('$_baseUrl/top/anime');
      
      // 5. Cek apakah panggilan API berhasil (Status Code 200 = OK)
      if (response.statusCode == 200) {
        
        // 6. API Jikan mengembalikan data di dalam kunci 'data'
        //    Kita ambil list tersebut
        final List<dynamic> data = response.data['data'];
        
        // 7. Ubah setiap item di list JSON mentah menjadi objek Anime
        //    (Menggunakan 'Anime.fromJson' yang sudah kita buat di model)
        return data.map((json) => Anime.fromJson(json)).toList();
      } else {
        // Jika status code bukan 200, lempar error
        throw Exception('Failed to load anime list (Status code: ${response.statusCode})');
      }
    } catch (e) {
      // 8. Tangani error (misal tidak ada koneksi internet)
      print(e); // Cetak error ke konsol untuk debugging
      throw Exception('Failed to load anime list: $e');
    }
  }
}