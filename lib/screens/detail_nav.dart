import 'package:fasolasync/screens/playlist_detail.dart';
import 'package:flutter/material.dart';
import 'package:fasolasync/screens/library.dart';
// import '/screens/library.dart';

class DetailPlayerScreen extends StatefulWidget {
  const DetailPlayerScreen({Key? key}) : super(key: key);

  @override
  DetailPlayerScreenState createState() => DetailPlayerScreenState();
}

class DetailPlayerScreenState extends State<DetailPlayerScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A55A2)),
        ),
        title: const Text(
          'Playlist Detail',
          style: TextStyle(color: Color(0xFF4A55A2)),
        ),
        backgroundColor: Colors.white,
      ),
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
        return PlaylistDetail();
      case 1:
        return libraryPage();
      default:
        return Container();
    }
  }
}
