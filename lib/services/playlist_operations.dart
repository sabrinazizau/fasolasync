import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tugas5/models/playlist_model.dart';
import '../config.dart';
import '../restapi.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
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
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(75.0),
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
          padding: EdgeInsets.only(bottom: 8.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: playlist.length,
          itemBuilder: (context, index) {
            final item = playlist[index];

            return InkWell(
              key: ValueKey(item.id),
              onTap: () {
                Navigator.pushNamed(context, 'playlist_detail',
                    arguments: [item.id]).then((value) => selectAllPlaylist());
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
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 200,
                  height: 200,
                  color: Color(0xFF4A55A2), // Warna latar belakang placeholder
                  child: Center(
                    child: Icon(
                      Icons.music_note,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '$albumTitle',
                  textAlign: TextAlign.center, // Teks berada di tengah
                  style: TextStyle(
                    fontSize: 16,
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
}
