// Hapus baris 'import 'dart.convert';' dari sini

class Anime {
  // 1. Definisikan data yang ingin kita ambil dari API
  final int malId; // ID unik dari anime, penting untuk fitur favorit
  final String title;
  final double score;
  final String synopsis;
  final String imageUrl; // URL untuk poster anime

  // --- TAMBAHKAN FIELD BARU ---
  final String rating; // Misal "PG-13"
  final int? episodes; // Bisa jadi null jika 'Airing'
  final List<String> genres; // Daftar genre

  // 2. Constructor standar
  Anime({
    required this.malId,
    required this.title,
    required this.score,
    required this.synopsis,
    required this.imageUrl,
    // --- TAMBAHKAN DI CONSTRUCTOR ---
    required this.rating,
    this.episodes,
    required this.genres,
  });

  // 3. 'Constructor' khusus: untuk membuat objek Anime dari data JSON API
  factory Anime.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map<String, dynamic>?;
    final jpg = images?['jpg'] as Map<String, dynamic>?;

    // Helper untuk mengambil list genre
    final List<dynamic> genreList = json['genres'] as List<dynamic>? ?? [];
    final List<String> genreNames =
        genreList.map((g) => g['name'] as String).toList();

    return Anime(
      malId: json['mal_id'] as int,
      title: json['title'] as String? ?? 'No Title',
      score: (json['score'] as num? ?? 0.0).toDouble(),
      synopsis: json['synopsis'] as String? ?? 'No synopsis available.',
      imageUrl: jpg?['image_url'] as String? ??
          'https://placehold.co/500x700/DDDDDD/000000?text=No+Poster',

      // --- PARSING DATA BARU ---
      rating: json['rating'] as String? ?? 'Unknown',
      episodes: json['episodes'] as int?, // Boleh null
      genres: genreNames,
    );
  }

  // 4. Method untuk mengubah objek Anime kembali ke Map
  Map<String, dynamic> toJson() => {
        'mal_id': malId,
        'title': title,
        'score': score,
        'synopsis': synopsis,
        'image_url': imageUrl,
        // --- TAMBAHKAN DATA BARU ---
        'rating': rating,
        'episodes': episodes,
        'genres': genres,
      };

  // 5. 'Constructor' khusus: untuk membuat objek Anime dari data JSON SharedPreferences
  factory Anime.fromJsonString(Map<String, dynamic> json) {
    return Anime(
      malId: json['mal_id'] as int,
      title: json['title'] as String,
      score: json['score'] as double,
      synopsis: json['synopsis'] as String,
      imageUrl: json['image_url'] as String,

      // --- PARSING DATA BARU ---
      rating: json['rating'] as String,
      episodes: json['episodes'] as int?,
      // Pastikan 'genres' di-parsing kembali sebagai List<String>
      genres:
          (json['genres'] as List<dynamic>).map((g) => g as String).toList(),
    );
  }
}
