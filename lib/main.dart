import 'package:catatan_keuangan/firebase_options.dart';
import 'package:catatan_keuangan/view/detail_view.dart';
import 'package:catatan_keuangan/view/home_view.dart';
import 'package:catatan_keuangan/view/register_view.dart';
import 'package:catatan_keuangan/view/tambah_view.dart';
import 'package:catatan_keuangan/view/update_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:catatan_keuangan/view/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return MaterialApp(
      title: 'Catatan Keuangan',
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      initialRoute: user == null ? '/login' : '/home',
      routes: {
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/home': (context) => const HomeView(),
        '/tambah': (context) => const TambahPage(),
        '/update': (context) => const UpdatePage(),
        '/detail': (context) => const DetailPage(),
      },
    );
  }
}
