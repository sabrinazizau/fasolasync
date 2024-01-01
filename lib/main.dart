import 'package:fasolasync/screens/detail_nav.dart';
import 'package:fasolasync/screens/detailz.dart';
import 'package:fasolasync/screens/list_song.dart';
import 'package:fasolasync/screens/playlist_form_edit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:fasolasync/admin/song_form_add.dart';
import 'package:fasolasync/screens/library.dart';
import 'package:fasolasync/screens/playlist_detail.dart';
import 'package:fasolasync/screens/playlist_form_add.dart';
import 'package:fasolasync/screens/playlist_list.dart';
import 'package:fasolasync/screens/register_page.dart';
import 'package:fasolasync/services/playlist_operations.dart';
import '/screens/nav_bar.dart';
import '/screens/home.dart';
import 'firebase_options.dart';
import 'package:fasolasync/screens/login_page.dart';

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
        'home': (context) => const MusicPlayerScreen(),
        'login_page': (context) => const LoginPage(),
        'register_page': (context) => const RegisterPage(),
        'playlist_form_add': (context) => const PlaylistFormAdd(),
        'playlist_operations': (context) => const HomeContent(),
        'detailz' : (context) => const DetailPlayliztScreen(),
        'detail_nav': (context) => const DetailPlayerScreen(),
        'playlist_detail': (context) => const PlaylistDetail(),
        'playlist_list': (context) => const PlaylistList(),
        'library': (context) => const libraryPage(),
        'playlist_form_edit': (context) => const PlaylistFormEdit(),
        'list_song': (context) => const ListSong(),
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
            User? user = snapshot.data;
            if (user != null) {
              return NavBarDemo(user: user);
            } else {
              return const NavBarDemo(user: null);
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      splashTransition: SplashTransition.scaleTransition,
      pageTransitionType: PageTransitionType.fade,
      duration: 2000,
    );
  }
}
