import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/library.dart';
import '../services/playlist_operations.dart';
import '../utils/rounded_button.dart';
import '../screens/login_page.dart';
import '../screens/register_page.dart';
//

class NavBarDemo extends StatefulWidget {
  final User? user; // User bisa null jika belum login

  const NavBarDemo({Key? key, required this.user});

  @override
  _NavBarDemoState createState() => _NavBarDemoState();
}

class _NavBarDemoState extends State<NavBarDemo> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.user != null
          ? _buildLoggedInAppBar()
          : _buildLoggedOutAppBar(),
      drawer: widget.user != null
          ? Drawer(
              backgroundColor: Colors.white,
              child: ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text('${widget.user!.displayName ?? ""}'),
                    accountEmail: Text('${widget.user!.email ?? ""}'),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person),
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A55A2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        color: Color(0xFF4A55A2),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.home,
                      color: Color(0xFF4A55A2),
                    ),
                    title: Text(
                      'Home',
                      style: TextStyle(
                        color: Color(0xFF4A55A2),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Tutup drawer
                      _onBottomNavItemTapped(0);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.library_music,
                      color: Color(0xFF4A55A2),
                    ),
                    title: Text(
                      'Library',
                      style: TextStyle(
                        color: Color(0xFF4A55A2),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Tutup drawer
                      _onBottomNavItemTapped(1);
                    },
                  ),
                  // SizedBox(
                  //   height: 40,
                  //   width: double.infinity,
                  //   child: RoundedButton(
                  //     colour: Colors.white,
                  //     title: 'Add Playlist',
                  //     onPressed: () {
                  //       Navigator.pushNamed(context, 'playlist_form_add');
                  //     },
                  //   ),
                  // ),

                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        color: Color(0xFF4A55A2),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.account_circle,
                      color: Color(0xFF4A55A2),
                    ),
                    title: Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Color(0xFF4A55A2),
                      ),
                    ),
                    onTap: () {
                      // Handle navigation to the profile edit page
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.logout,
                      color: Color(0xFF4A55A2),
                    ),
                    title: Text(
                      'Logout Account',
                      style: TextStyle(
                        color: Color(0xFF4A55A2),
                      ),
                    ),
                    onTap: _handleLogout,
                  ),
                ],
              ),
            )
          : null,
      body: Row(
        children: <Widget>[
          NavigationRail(
            backgroundColor: Color(0xFF4A55A2),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home, color: Colors.white),
                label: Text('Home', style: TextStyle(color: Colors.white)),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.library_music, color: Colors.white),
                label: Text('Library', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
          ),
          Expanded(
            child: Center(
              child:
                  _buildContent(), // Display content based on the selected tab
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return HomeContent();
      case 1:
        return libraryPage();
      default:
        return Container();
    }
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      leading: Builder(builder: (BuildContext context) {
        return IconButton(
          icon: const Icon(
            Icons.multitrack_audio_sharp,
            color: Color(0xFF4A55A2),
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      }),
      title: Text(
        'FaSoLaSync',
        style: TextStyle(color: Color(0xFF4A55A2), fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.white,
    );
  }

  AppBar _buildLoggedOutAppBar() {
    print("Building Logged Out Appbar");
    return AppBar(
      //iconTheme: IconThemeData(color: Colors.black),
      title: Text(
        'FaSoLaSync',
        style: TextStyle(
          color: Color(0xFF4A55A2),
        ),
      ),
      backgroundColor: Colors.white,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()));
          },
          child: Text(
            'Log In',
            style: TextStyle(color: Color(0xFF4A55A2)),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => RegisterPage()));
          },
          child: Text(
            'Sign Up',
            style: TextStyle(color: Color(0xFF4A55A2)),
          ),
        ),
      ],
    );
  }
}
