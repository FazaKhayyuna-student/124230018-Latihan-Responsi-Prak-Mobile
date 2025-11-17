import 'package:flutter/material.dart';
// Import halaman-halaman yang akan kita buat selanjutnya
// INI AKAN MERAH DULU, DAN ITU NORMAL!
import 'package:my_anime_archive/views/home_page.dart';
import 'package:my_anime_archive/views/favorites_page.dart';
import 'package:my_anime_archive/views/profile_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // 1. Variabel untuk menyimpan 'index' tab yang sedang aktif
  int _selectedIndex = 0;

  // 2. Daftar semua halaman/widget yang akan ditampilkan
  //    Urutannya HARUS SAMA dengan urutan 'items' di BottomNavigationBar
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(), // Index 0
    FavoritesPage(), // Index 1
    ProfilePage(), // Index 2
  ];

  // 3. Fungsi yang dipanggil saat user menekan salah satu tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update index yang aktif
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 4. Body akan menampilkan halaman yang aktif
      //    berdasarkan '_selectedIndex'
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      
      // 5. Definisikan Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // Tombol Tab Home
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          // Tombol Tab Favorites
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          // Tombol Tab Profile
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex, // Tentukan tab mana yang aktif
        selectedItemColor: Colors.purple, // Warna tab yang aktif
        onTap: _onItemTapped, // Panggil fungsi ini saat tab ditekan
      ),
    );
  }
}