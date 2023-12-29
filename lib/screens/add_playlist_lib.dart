import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/playlist_model.dart';
import '../config.dart';
import '../restapi.dart';

class AddPlaylistLib extends StatefulWidget {
  const AddPlaylistLib({Key? key}) : super(key: key);

  @override
  _AddPlaylistLibState createState() => _AddPlaylistLibState();
}

bool isUserLoggedIn() {
  User? user = FirebaseAuth.instance.currentUser;
  return user != null;
}

class _AddPlaylistLibState extends State<AddPlaylistLib> {
  final searchKeyword = TextEditingController();
  bool searchStatus = false;

  DataService ds = DataService();

  List<PlaylistModel> playlist = [];

  selectAllPlaylist() async {
    try {
      List data =
          jsonDecode(await ds.selectAll(token, project, 'playlist', appid));

      if (data != null) {
        setState(() {
          playlist = data.map((e) => PlaylistModel.fromJson(e)).toList();
        });
      } else {
        setState(() {
          playlist = [];
        });
      }
    } catch (e) {
      print('Error fetching playlists: $e');
    }
  }

  @override
  void initState() {
    selectAllPlaylist();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // if(!isUserLoggedIn()) {
    // return loginPopup();
    // }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // onPressed: () => Navigator.of(context).pop(),
          onPressed: () {
            Navigator.pop(context, 'library');
          },
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A55A2)),
        ),
        title: const Text(
          'Add Playlist to Library',
          style:
              TextStyle(color: Color(0xFF4A55A2), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        padding: EdgeInsets.all(25.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD6E6F2),
              Color(0xFFA084DC),
            ],
          ),
        ),
        child: GridView.builder(
          padding: EdgeInsets.only(bottom: 10.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _calculateCrossAxisCount(screenWidth),
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: playlist.length,
          itemBuilder: (context, index) {
            final item = playlist[index];

            return InkWell(
              key: ValueKey(item.id),
              child: _buildAlbumCard(
                item.playlist_image ?? '',
                item.playlist_name,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAlbumCard(
    String? coverImage,
    String albumTitle,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    return Card(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (coverImage != null && coverImage.isNotEmpty)
                Flexible(
                  child: Image.network(
                    fileUri + '$coverImage',
                    width: screenWidth,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Flexible(
                  child: Container(
                    width: screenWidth,
                    color: Color(0xFF4A55A2),
                    child: Center(
                      child: Icon(
                        Icons.music_note,
                        size: 50 * textScaleFactor,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '$albumTitle',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16 * textScaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(
                  Icons.add,
                  size: 30 * textScaleFactor,
                  color: Colors.black,
                ),
                onPressed: () {
                  // Handle the add button press
                  // Add your logic here
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateCrossAxisCount(double screenWidth) {
    int minCrossAxisCount = 2;
    int maxCrossAxisCount = 5;

    int calculatedCrossAxisCount = (screenWidth / 200).floor();

    return calculatedCrossAxisCount.clamp(minCrossAxisCount, maxCrossAxisCount);
  }
}
