import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tugas5/firebase_options.dart';
import '/screens/nav_bar.dart';
import '/screens/home.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data as User?;
            if (user != null) {
              return Material(
                child: NavBarDemo(user: user),
              );
            } else {
              return Material(
                child: NavBarDemo(user: null),
              );
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
      routes: {
        'home': (context) => const MusicPlayerScreen(),
      },
    );
  }
}
