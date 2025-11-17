import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_anime_archive/models/anime.dart';
import 'package:my_anime_archive/viewmodels/main_view_model.dart';

class DetailPage extends StatelessWidget {
  final Anime anime;

  const DetailPage({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    // Kita 'watch' di sini agar icon love bisa update
    final viewModel = context.watch<MainViewModel>();
    final bool isFavorited = viewModel.isFavorite(anime.malId);

    return Scaffold(
      // Kita ganti body biasa dengan CustomScrollView
      body: CustomScrollView(
        slivers: [
          // 1. Ini adalah AppBar yang bisa kolaps
          _buildSliverAppBar(context, anime, isFavorited, viewModel),

          // 2. Ini adalah konten (Sinopsis, Score)
          _buildSliverContent(context, anime),
        ],
      ),
    );
  }

  // WIDGET BARU: untuk membuat AppBar
  Widget _buildSliverAppBar(BuildContext context, Anime anime, bool isFavorited,
      MainViewModel viewModel) {
    return SliverAppBar(
      // Tinggi AppBar saat 'terbuka' penuh
      expandedHeight: 350.0,
      // AppBar akan tetap 'menempel' di atas saat di-scroll
      pinned: true,
      // Efek 'parallax' saat scroll
      floating: false,
      backgroundColor: Colors.purple, // Warna tema

      // Tombol Aksi (Icon Love)
      actions: [
        IconButton(
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? Colors.red : Colors.white, // Border putih
          ),
          onPressed: () {
            // 'listen: false' karena di dalam fungsi
            Provider.of<MainViewModel>(context, listen: false)
                .toggleFavorite(anime);
          },
        ),
      ],

      // 'flexibleSpace' adalah area yang bisa kolaps
      flexibleSpace: FlexibleSpaceBar(
        // Judul yang akan mengecil
        title: Text(
          anime.title,
          style: const TextStyle(
            fontSize: 16,
            // Beri bayangan agar teks terbaca di atas gambar
            shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
          ),
        ),
        // Atur padding agar judul tidak mentok
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 100),

        // Latar belakang 'flexibleSpace'
        background:
            // 3. INI ADALAH HERO ANIMATION
            Hero(
          tag: anime.malId, // Tag harus unik, kita pakai ID anime
          child: CachedNetworkImage(
            imageUrl: anime.imageUrl,
            fit: BoxFit.cover, // Wajib agar memenuhi header
            placeholder: (context, url) => Container(color: Colors.grey[200]),
            errorWidget: (context, url, error) =>
                const Icon(Icons.broken_image),
          ),
        ),
      ),
    );
  }

  // WIDGET BARU: untuk membuat konten 'sheet'
  Widget _buildSliverContent(BuildContext context, Anime anime) {
    // 'SliverToBoxAdapter' adalah jembatan
    // antara 'sliver' dan 'widget' biasa (seperti Container)
    return SliverToBoxAdapter(
      child: Container(
        // 4. EFEK SHEET (Lembaran)
        // 'transform' ini akan 'menarik' container ke atas
        // sehingga menutupi sedikit bagian bawah AppBar (overlap)

        // HAPUS BARIS INI:
        // transform: Matrix4.translationValues(0.0, -20.0, 0.0),

        decoration: BoxDecoration(
          // GANTI WARNA INI:
          // color: Theme.of(context).scaffoldBackgroundColor, // Warna latar
          // MENJADI INI:
          color: Colors.white, // Pastikan warnanya putih

          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),

        // GANTI PADDING INI:
        // padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
        // MENJADI INI (agar pas):
        padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 5. UPGRADE UI SCORE (menggunakan Chip)
            //    KITA GANTI MENJADI 'Wrap'
            Wrap(
              spacing: 8.0, // Jarak horizontal antar chip
              runSpacing: 4.0, // Jarak vertikal antar baris
              children: [
                // Chip Score (seperti sebelumnya)
                Chip(
                  avatar: const Icon(Icons.star,
                      color: Colors.deepOrange, size: 20),
                  label: Text(
                    "Score: ${anime.score}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.deepOrange.withValues(alpha: 0.1),
                ),

                // --- TAMBAHKAN CHIP BARU ---

                // Chip Rating
                Chip(
                  avatar:
                      const Icon(Icons.security, color: Colors.blue, size: 20),
                  label: Text(
                    anime.rating,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                ),

                // Chip Episodes
                if (anime.episodes != null)
                  Chip(
                    avatar: const Icon(Icons.tv, color: Colors.green, size: 20),
                    label: Text(
                      "${anime.episodes} Episodes",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Colors.green.withValues(alpha: 0.1),
                  ),

                // Chip Genres (Looping)
                ...anime.genres.map((genre) => Chip(
                      label: Text(
                        genre,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: Colors.grey.shade200,
                    )),
              ],
            ),
            const SizedBox(height: 20),

            // Teks Sinopsis (Judul)
            const Text(
              "Synopsis:",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Teks Sinopsis (Isi)
            Text(
              anime.synopsis.isEmpty
                  ? "No synopsis available."
                  : anime.synopsis,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5, // Jarak antar baris
                color: Colors.black87, // Sedikit lebih lembut
              ),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
