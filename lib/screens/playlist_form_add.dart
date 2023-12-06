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
  final gambar_aset = TextEditingController();
  final song_id = TextEditingController();

  DataService ds = DataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Playlist Form Add"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //Description Task
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
                      backgroundColor: Colors.lightGreen, elevation: 0),
                  onPressed: () async {
                    List response = jsonDecode(await ds.insertPlaylist(appid,
                        playlist_name.text, "-", playlist_desc.text, "-"));

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
