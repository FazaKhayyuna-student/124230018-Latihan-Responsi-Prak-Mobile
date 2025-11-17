import 'package:hive/hive.dart';

// 1. Memberitahu file ini untuk menyertakan file lain
//    (yang akan kita generate nanti).
//    Ini mungkin akan merah/error dulu, itu NORMAL.
part 'user.g.dart';

// 2. Memberitahu Hive bahwa kelas ini adalah Tipe '0'
@HiveType(typeId: 0)
class User extends HiveObject {
  // 3. Memberitahu Hive ini adaslah field '0'
  @HiveField(0)
  String username;

  // 4. Memberitahu Hive ini adalah field '1'
  @HiveField(1)
  String password;

  // 5. Kita tambahkan juga data statis sesuai soal
  //    (Foto, Nama, NIM boleh statis)
  @HiveField(2)
  String fullName;

  @HiveField(3)
  String nim;

  // 6. Ini adalah 'Constructor' (pembuat) objek User
  User({
    required this.username,
    required this.password,
    // Kita isi data statisnya di sini
    this.fullName = 'Praktikan Mobile SI-B',
    this.nim = '123210000', // Ganti dengan NIM Anda jika mau
  });
}
