import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tugas5/models/playlist_model.dart';

import '../config.dart';
import '../restapi.dart';

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final searchKeyword = TextEditingController();
  bool searchStatus = false;

  DataService ds = DataService();

  List<PlaylistModel> playlist = [];

  selectAllPlaylist() async {
    List data =
        jsonDecode(await ds.selectAll(token, project, 'playlist', appid));

    setState(() {
      playlist = data.map((e) => PlaylistModel.fromJson(e)).toList();
    });
  }

  @override
  void initState() {
    selectAllPlaylist();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: playlist.length,
        itemBuilder: (context, index) {
          final item = playlist[index];

          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, 'playlist_detail',
                  arguments: [item.id]).then((value) => selectAllPlaylist());
            },
            child: _buildAlbumCard(
              item.playlist_image ?? 'assets/indie1.jpg',
              item.playlist_name,
              200,
              200,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlbumCard(
    String coverImage,
    String albumTitle,
    double maxImageWidth,
    double maxImageHeight,
  ) {
    return Container(
      width: maxImageWidth,
      child: Card(
        child: Column(
          children: [
            coverImage.isNotEmpty
                ? Image.network(
                    '$coverImage',
                    width: maxImageWidth,
                    height: maxImageHeight,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: maxImageWidth,
                    height: maxImageHeight,
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 50, // Adjust the size as needed
                        color: Colors.grey, // Adjust the color as needed
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$albumTitle',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
