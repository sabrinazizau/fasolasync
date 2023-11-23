import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tugas5/screens/library.dart';
import 'package:tugas5/services/album_operations.dart';
import '/screens/home.dart';
import '/screens/login_page.dart';
import 'package:tugas5/screens/register_page.dart';

class NavBarDemo extends StatefulWidget {
  final User? user; // User bisa null jika belum login

  const NavBarDemo({Key? key, required this.user});

  @override
  _NavBarDemoState createState() => _NavBarDemoState();
}

class _NavBarDemoState extends State<NavBarDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.user != null
          ? _buildLoggedInAppBar()
          : _buildLoggedOutAppBar(),
      drawer: widget.user != null
          ? Drawer(
              child: ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text('${widget.user!.displayName ?? ""}'),
                    accountEmail: Text('${widget.user!.email ?? ""}'),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text('Menu'),
                  ),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeContent(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.library_music),
                    title: Text('Library'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text("Settings"),
                  ),
                  ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text('Edit Profile'),
                    onTap: () {
                      // Handle navigation to the profile edit page
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout Account'),
                    onTap: _handleLogout,
                  ),
                ],
              ),
            )
          : null,
      body: Center(
        child: MusicPlayerScreen(),
      ),
    );
  }

  void _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Error during logout: $e");
    }
    setState(() {});
  }

  AppBar _buildLoggedInAppBar() {
    print("Building Logged In Appbar");
    setState(() {});
    return AppBar(
      title: Text('FaSoLaSync'),
    );
  }

  AppBar _buildLoggedOutAppBar() {
    print("Building Logged Out Appbar");
    return AppBar(
      title: Text('FaSoLaSync'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()));
          },
          child: Text(
            'Log In',
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => RegisterPage()));
          },
          child: Text(
            'Sign Up',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
