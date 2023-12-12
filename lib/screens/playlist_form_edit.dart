import 'dart:convert';

import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../config.dart';
import '../restapi.dart';

class PlaylistFormEdit extends StatefulWidget {
  const PlaylistFormEdit({Key? key}) : super(key: key);

  @override
  PlaylistFormEditState createState() => PlaylistFormEditState();
}

class PlaylistFormEditState extends State<PlaylistFormEdit> {
  DataService ds = DataService();

  final playlist_name = TextEditingController();
  final playlist_desc = TextEditingController();
  // final playlist_image = TextEditingController();
  String playlist_image = '';
  String song_id = '';

  String update_id = '';
  bool loadData = false;

  List<PlaylistModel> playlist = [];

  selectIdPlaylist(String id) async {
    List data = [];
    data = jsonDecode(await ds.selectId(token, project, 'playlist', appid, id));

    playlist = data.map((e) => PlaylistModel.fromJson(e)).toList();

    setState(() {
      update_id = playlist[0].id;
      playlist_name.text = playlist[0].playlist_name;
      playlist_desc.text = playlist[0].playlist_desc;
      playlist_image = playlist[0].playlist_image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as List<String>;

    if (loadData == false) {
      selectIdPlaylist(args[0]);

      loadData = true;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A55A2)),
        ),
        title: const Text(
          'Edit Playlist',
          style: TextStyle(color: Color(0xFF4A55A2)),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.save,
              color: Color(0xFF4A55A2),
            ),
            onPressed: () {
              // Implement save functionality
              saveChanges();
              Navigator.of(context).pop(); // Close the form after saving
            },
          ),
        ],
      ),
      body: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Playlist Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: playlist_name,
                decoration: InputDecoration(
                  hintText: 'Enter playlist name',
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Playlist Description',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextFormField(
                controller: playlist_desc,
                decoration: InputDecoration(
                  hintText: 'Enter playlist description',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveChanges() async {
    bool updateStatus = await ds.updateId(
        'playlist_name~playlist_image~playlist_desc~song_id',
        playlist_name.text +
            '~' +
            playlist_image +
            '~' +
            playlist_desc.text +
            '~' +
            song_id,
        token,
        project,
        'playlist',
        appid,
        update_id);
  }
}
