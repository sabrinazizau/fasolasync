import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/playlist_model.dart';
import '../config.dart';
import '../restapi.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

bool isUserLoggedIn() {
  User? user = FirebaseAuth.instance.currentUser;
  return user != null;
}

class _HomeContentState extends State<HomeContent> {
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
      // Print or log the error
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
              onTap: () {
                if (isUserLoggedIn()) {
                  Navigator.pushNamed(context, 'playlist_detail',
                          arguments: [item.id])
                      .then((value) => selectAllPlaylist());
                } else {
                  showLoginPopup();
                }
              },
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
    final screenHeight = MediaQuery.of(context).size.height;
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
                    height: screenHeight,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Flexible(
                  child: Container(
                    width: screenWidth,
                    height: screenHeight,
                    color:
                        Color(0xFF4A55A2), // Warna latar belakang placeholder
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
                  textAlign: TextAlign.center, // Teks berada di tengah
                  style: TextStyle(
                    fontSize: 16 * textScaleFactor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  int _calculateCrossAxisCount(double screenWidth) {
    // Hitung jumlah kolom berdasarkan lebar layar
    int minCrossAxisCount = 2;
    int maxCrossAxisCount = 5;

    int calculatedCrossAxisCount = (screenWidth / 200).floor();

    // Pastikan nilai berada di antara min dan max
    return calculatedCrossAxisCount.clamp(minCrossAxisCount, maxCrossAxisCount);
  }

  void showLoginPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Login Required"),
          content: Text("You need to log in to access this content."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup popup login
                // Navigasi ke halaman login
                Navigator.pushNamed(context, 'login_page');
              },
              child: Text("LOGIN"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }
}
