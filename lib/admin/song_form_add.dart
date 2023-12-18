import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/Song_model.dart';

import '../restapi.dart';
import '../config.dart';

class SongFormAdd extends StatefulWidget {
  const SongFormAdd({Key? key}) : super(key: key);

  @override
  _SongFormAddState createState() => _SongFormAddState();
}

class _SongFormAddState extends State<SongFormAdd> {
  final title = TextEditingController();
  final artist = TextEditingController();
  // final duration = TextEditingController();
  // final url_song = TextEditingController();

  String url_song = '';
  late ValueNotifier<int> _notifier;

  DataService ds = DataService();

  Future<void> openFileExplorer() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'mp4'],
      );

      if (result != null) {
        var response = await ds.upload(token, project,
            result.files.first.bytes!, result.files.first.extension.toString());

        var file = jsonDecode(response);

        setState(() {
          url_song = fileUri + file['file_name'];
        });
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
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
            //Description Task
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: title,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Title',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextField(
                controller: artist,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Artist',
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            //   child: TextField(
            //     controller: duration,
            //     keyboardType: TextInputType.text,
            //     decoration: const InputDecoration(
            //       border: OutlineInputBorder(),
            //       hintText: 'Duration',
            //     ),
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: ElevatedButton(
                onPressed: openFileExplorer,
                child: Text('Choose File'),
              ),
            ),
            if (url_song != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  'Selected File: $url_song',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                      backgroundColor: Color(0xFF4A55A2), elevation: 0),
                  onPressed: () async {
                    List response = jsonDecode(await ds.insertSongs(
                        appid, title.text, artist.text, url_song));

                    List<SongsModel> Songs =
                        response.map((e) => SongsModel.fromJson(e)).toList();

                    if (Songs.length == 1) {
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
