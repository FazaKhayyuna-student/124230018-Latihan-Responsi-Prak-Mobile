import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_anime_archive/viewmodels/main_view_model.dart';
import 'package:my_anime_archive/models/anime.dart';
import 'package:my_anime_archive/views/detail_page.dart';

// Enum untuk Sort (tidak berubah)
enum SortCriteria { none, score, title }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Semua state dan controller ini tidak berubah
  final _searchController = TextEditingController();
  String _searchQuery = "";
  SortCriteria _sortCriteria = SortCriteria.none;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Semua fungsi logika ini tidak berubah
  void _fetchData() {
    Provider.of<MainViewModel>(context, listen: false).fetchTopAnime();
  }

  void _goToDetail(Anime anime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(anime: anime),
      ),
    );
  }

  void _setSortCriteria(SortCriteria criteria) {
    setState(() {
      _sortCriteria = criteria;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MainViewModel>();

    // Logika Search & Sort (tidak berubah)
    List<Anime> displayedList = List.from(viewModel.topAnimeList);
    if (_searchQuery.isNotEmpty) {
      displayedList = displayedList.where((anime) {
        return anime.title.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    if (_sortCriteria == SortCriteria.score) {
      displayedList.sort((a, b) => b.score.compareTo(a.score));
    } else if (_sortCriteria == SortCriteria.title) {
      displayedList.sort((a, b) => a.title.compareTo(b.title));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Top Anime',
          style: TextStyle(
            color: Colors.grey[900],
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: _buildSearchBar(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _buildSortButtons(),
          ),
          Expanded(
            child: viewModel.isLoading && _searchQuery.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _buildAnimeGrid(displayedList),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  // Search Bar - polished design
  Widget _buildSearchBar() {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari judul anime...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  // Sort Buttons - using ChoiceChip for cleaner look
  Widget _buildSortButtons() {
    final primary = Theme.of(context).colorScheme.primary;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        ChoiceChip(
          label: const Text('Default'),
          selected: _sortCriteria == SortCriteria.none,
          onSelected: (_) => _setSortCriteria(SortCriteria.none),
        ),
        ChoiceChip(
          label: const Text('By Title'),
          selected: _sortCriteria == SortCriteria.title,
          selectedColor: primary,
          onSelected: (_) => _setSortCriteria(SortCriteria.title),
        ),
        ChoiceChip(
          label: const Text('By Score'),
          selected: _sortCriteria == SortCriteria.score,
          selectedColor: primary,
          onSelected: (_) => _setSortCriteria(SortCriteria.score),
        ),
      ],
    );
  }

  // --- INI PERUBAHAN BESARNYA ---

  // 1. FUNGSI INI MENGGANTIKAN '_buildAnimeList'
  Widget _buildAnimeGrid(List<Anime> animeList) {
    if (animeList.isEmpty) {
      return const Center(
        child: Text(
          "Tidak ada anime ditemukan.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // GANTI DARI LISTVIEW KE GRIDVIEW
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),

      // Definisikan layout grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 kolom, ini akan terlihat jauh lebih baik
        childAspectRatio: 0.65, // Rasio Lebar:Tinggi (untuk poster)
        crossAxisSpacing: 10, // Jarak horizontal
        mainAxisSpacing: 10, // Jarak vertikal
      ),

      itemCount: animeList.length,
      itemBuilder: (context, index) {
        final anime = animeList[index];
        // 2. Kita panggil 'widget card' kustom baru
        return _buildAnimeCard(anime);
      },
    );
  }

  // 3. WIDGET BARU UNTUK MEMBUAT KARTU GRID YANG CANTIK
  Widget _buildAnimeCard(Anime anime) {
    return Card(
      // Card styling
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias, // Penting agar gambar tidak 'bocor'

      // InkWell agar bisa diklik dan ada efek ripple
      child: InkWell(
        onTap: () {
          _goToDetail(anime); // Aksi klik
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- BAGIAN POSTER ---
            Expanded(
              child: CachedNetworkImage(
                imageUrl: anime.imageUrl,
                fit: BoxFit.cover, // Wajib agar poster memenuhi frame
                placeholder: (context, url) =>
                    Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.broken_image, size: 50),
              ),
            ),

            // --- BAGIAN INFO TEKS ---
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    anime.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 2, // Maksimal 2 baris
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Score
                  Text(
                    "Score: ${anime.score.toString()}",
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
