import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/playlist_model.dart';

import '../restapi.dart';
import '../config.dart';

class PlaylistFormAdd extends StatefulWidget {
  const PlaylistFormAdd({Key? key}) : super(key: key);

  @override
  _PlaylistFormAddState createState() => _PlaylistFormAddState();
}

class _PlaylistFormAddState extends State<PlaylistFormAdd> {
  final playlist_name = TextEditingController();
  final playlist_desc = TextEditingController();
  final playlist_image = TextEditingController();
  final gambar_aset = TextEditingController();
  final song_id = TextEditingController();

  DataService ds = DataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            // Navigate back to the previous screen (libraryPage)
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A55A2)),
        ),
        title: const Text(
          'Playlist Form Add',
          style: TextStyle(color: Color(0xFF4A55A2)),
        ),
        backgroundColor: Colors.white,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Description Task
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: playlist_name,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Playlist Name',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: playlist_desc,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Description',
                ),
              ),
            ),
            // Submit Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    List response = jsonDecode(await ds.insertPlaylist(appid,
                        playlist_name.text, "", playlist_desc.text, "-"));

                    List<PlaylistModel> Playlist =
                        response.map((e) => PlaylistModel.fromJson(e)).toList();

                    if (Playlist.length == 1) {
                      Navigator.pop(context, true);
                    } else {
                      if (kDebugMode) {
                        print(response);
                      }
                    }
                  },
                  child: const Text('SUBMIT'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
