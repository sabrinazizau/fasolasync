import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fasolasync/config.dart';
import 'package:fasolasync/models/playlist_model.dart';
import 'package:fasolasync/restapi.dart';

class libraryPage extends StatefulWidget {
  const libraryPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  libraryPageState createState() => libraryPageState();
}

class libraryPageState extends State<libraryPage> {
  final searchKeyword = TextEditingController();
  bool searchStatus = false;

  DataService ds = DataService();

  List data = [];
  List<PlaylistModel> playlist = [];

  List<PlaylistModel> search_data = [];
  List<PlaylistModel> search_data_pre = [];

  selectAllPlaylist() async {
    data = jsonDecode(await ds.selectAll(token, project, 'playlist', appid));

    playlist = data.map((e) => PlaylistModel.fromJson(e)).toList();

    setState(() {
      playlist = playlist;
    });
  }

  Future reloadDataPlaylist(dynamic value) async {
    setState(() {
      selectAllPlaylist();
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
        child: Center(
          child: Text(
            'Your Library',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
