import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/Song_model.dart';

import '../restapi.dart';
import '../config.dart';
import '../screens/nav_bar.dart';

class SongFormAdd extends StatefulWidget {
  const SongFormAdd({Key? key}) : super(key: key);

  @override
  _SongFormAddState createState() => _SongFormAddState();
}

class _SongFormAddState extends State<SongFormAdd> {
  final title = TextEditingController();
  final artist = TextEditingController();
  bool isLoading = false;

  String url_song = '';
  late ValueNotifier<int> _notifier;

  DataService ds = DataService();

  @override
  void initState() {
    super.initState();
    checkAdminRole();
  }

  Future<void> checkAdminRole() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      String userRole = userData['role'];

      if (userRole != 'admin') {
        Navigator.pop(context);
      }
    }
  }

  Future<void> openFileExplorer() async {
    setState(() {
      isLoading = true;
    });
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
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Song submitted successfully!'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          "Song Form Add",
          style: TextStyle(color: Color(0xFF4A55A2)),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => NavBarDemo(user: null),
                ),
              );
            },
            icon: Icon(
              Icons.logout,
              color: Color(0xFF4A55A2),
            ),
          ),
        ],
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
            if (isLoading)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (url_song != null)
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
                      await showSuccessDialog();
                      setState(() {
                        title.text = '';
                        artist.text = '';
                        url_song = '';
                      });
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
