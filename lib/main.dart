import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:tugas5/admin/song_form_add.dart';
import 'package:tugas5/screens/library.dart';
import 'package:tugas5/screens/list_song.dart';
import 'package:tugas5/screens/playlist_detail.dart';
import 'package:tugas5/screens/playlist_form_add.dart';
import 'package:tugas5/screens/playlist_form_edit.dart';
import 'package:tugas5/screens/playlist_list.dart';
import 'package:tugas5/screens/register_page.dart';
import 'package:tugas5/services/playlist_operations.dart';
import '/screens/nav_bar.dart';
import 'firebase_options.dart';
import 'package:tugas5/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaSoLaSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: SplashScreen(), // Menggunakan SplashScreen sebagai halaman awal
      routes: {
        'login_page': (context) => const LoginPage(),
        'register_page': (context) => const RegisterPage(),
        'playlist_form_add': (context) => const PlaylistFormAdd(),
        'playlist_operations': (context) => const HomeContent(),
        'playlist_detail': (context) => const PlaylistDetail(),
        'playlist_list': (context) => const PlaylistList(),
        'library': (context) => const libraryPage(),
        'list_song': (context) => ListSong(),
        'playlist_form_edit': (context) => const PlaylistFormEdit(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Image.asset(
          'assets/fasolasync.png',
          width: 4800,
          height: 4800,
          fit: BoxFit.contain,
        ),
      ),
      backgroundColor: Colors.white,
      nextScreen: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data as User?;
            if (user != null) {
              return NavBarDemo(user: user);
            } else {
              return NavBarDemo(user: null);
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
      splashTransition: SplashTransition.scaleTransition,
      pageTransitionType: PageTransitionType.fade,
      duration: 2000,
    );
  }
}
