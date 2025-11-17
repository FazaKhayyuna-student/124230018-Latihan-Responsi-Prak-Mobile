import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_anime_archive/models/user.dart';
import 'package:my_anime_archive/viewmodels/main_view_model.dart';
import 'package:my_anime_archive/views/main.navigation.dart';
import 'package:provider/provider.dart';

// Halaman-halaman (Masih placeholder, akan kita buat di langkah selanjutnya)
// INI AKAN MERAH DULU, DAN ITU NORMAL!
import 'package:my_anime_archive/views/login_page.dart';

void main() async {
  // 1. Pastikan Flutter binding siap sebelum menjalankan kode 'async'
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Hive di folder aplikasi
  await Hive.initFlutter();

  // 3. Register Adapter (file 'user.g.dart' yang tadi kita buat)
  //    Ini WAJIB dilakukan sebelum membuka box
  Hive.registerAdapter(UserAdapter());

  // 4. Jalankan Aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 5. Bungkus seluruh aplikasi dengan ChangeNotifierProvider
    //    Ini membuat 'MainViewModel' kita bisa diakses dari halaman manapun
    return ChangeNotifierProvider(
      create: (context) => MainViewModel(),
      child: MaterialApp(
        title: 'MyAnimeArchive',
        theme: ThemeData(
          primarySwatch: Colors.purple, // Tema warna
          scaffoldBackgroundColor: const Color(0xFFF0F2F5), // Warna latar
          useMaterial3: true,
          fontFamily: 'Inter', // Jika Anda menambahkan font kustom di pubspec
        ),
        debugShowCheckedModeBanner: false,
        // 6. 'home' akan diatur oleh AuthWrapper
        home: const AuthWrapper(),
      ),
    );
  }
}

// 7. Widget 'Gerbang' untuk mengecek Sesi Login
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // 8. Saat 'Gerbang' ini pertama kali dibuat,
    //    langsung panggil fungsi 'checkLoginSession' dari ViewModel
    //    'listen: false' wajib ada di dalam initState
    Provider.of<MainViewModel>(context, listen: false).checkLoginSession();
  }

  @override
  Widget build(BuildContext context) {
    // 9. Kita 'mendengarkan' perubahan data di MainViewModel
    return Consumer<MainViewModel>(
      builder: (context, viewModel, child) {
        // 10. SELAMA proses pengecekan sesi, tampilkan loading
        if (viewModel.isLoadingSession) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 11. JIKA pengecekan selesai dan user ADA (tidak null),
        //     arahkan ke Halaman Utama (MainNavigation)
        if (viewModel.currentUser != null) {
          return const MainNavigation(); // Ini masih akan merah
        }

        // 12. JIKA user TIDAK ADA (null),
        //     arahkan ke Halaman Login
        return const LoginPage(); // Ini masih akan merah
      },
    );
  }
}
