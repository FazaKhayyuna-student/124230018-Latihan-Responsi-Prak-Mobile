import 'package:flutter/material.dart';
import 'package:my_anime_archive/models/anime.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_anime_archive/viewmodels/main_view_model.dart';
import 'package:my_anime_archive/views/detail_page.dart'; // Import halaman detail

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  // 1. Panggil fungsi untuk load data favorit saat halaman ini dibuka
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  // 2. Fungsi untuk memanggil ViewModel
  void _loadFavorites() {
    // Panggil fungsi 'loadFavorites' dari ViewModel
    Provider.of<MainViewModel>(context, listen: false).loadFavorites();
  }

  // 3. Fungsi untuk navigasi ke Halaman Detail
  void _goToDetail(Anime anime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(anime: anime),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 4. 'Tonton' (watch) daftar favorit dari ViewModel
    final favoriteList = context.watch<MainViewModel>().favoriteList;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'My Favorites',
          style: TextStyle(
            color: Colors.grey[900],
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: favoriteList.isEmpty
          ? const Center(
              child: Text(
                "Anda belum punya anime favorit.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : _buildFavoriteList(favoriteList),
    );
  }

  // 6. Widget untuk membangun List
  Widget _buildFavoriteList(List<Anime> animeList) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      itemCount: animeList.length,
      itemBuilder: (context, index) {
        final anime = animeList[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _goToDetail(anime),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: anime.imageUrl,
                      width: 86,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 86,
                        height: 120,
                        color: Colors.grey[200],
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 86,
                        height: 120,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          anime.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star,
                                size: 14, color: Colors.amber[700]),
                            const SizedBox(width: 4),
                            Text(
                              'Score: ${anime.score}',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
