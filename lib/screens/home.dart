import 'package:flutter/material.dart';
import '../services/playlist_operations.dart';
// import '/screens/library.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({Key? key}) : super(key: key);

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.library_music),
                label: Text('Library'),
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
      // return ProfileScreen();
      default:
        return Container();
    }
  }
}
