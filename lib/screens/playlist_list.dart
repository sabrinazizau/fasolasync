import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fasolasync/models/playlist_model.dart';

import '/config.dart';
import '/restapi.dart';

class PlaylistList extends StatefulWidget {
  const PlaylistList({Key? key}) : super(key: key);

  @override
  PlaylistListState createState() => PlaylistListState();
}

class PlaylistListState extends State<PlaylistList> {
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

  void filterPlaylist(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      search_data = data.map((e) => PlaylistModel.fromJson(e)).toList();
    } else {
      search_data_pre = data.map((e) => PlaylistModel.fromJson(e)).toList();
      search_data = search_data_pre
          .where((user) => user.playlist_name
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    //Refresh the UI
    setState(() {
      playlist = search_data;
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
      appBar: AppBar(
        title: !searchStatus ? const Text("Playlist List") : search_field(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, 'playlist_form_add')
                    .then(reloadDataPlaylist);
              },
              child: const Icon(
                Icons.add,
                size: 26.0,
              ),
            ),
          ),
          search_icon(),
        ],
      ),
      body: ListView.builder(
        itemCount: playlist.length,
        itemBuilder: (context, index) {
          final item = playlist[index];

          return ListTile(
            title: Text(item.playlist_name),
            subtitle: Text(item.playlist_desc),
            onTap: () {
              Navigator.pushNamed(context, 'playlist_detail',
                  arguments: [item.id]).then(reloadDataPlaylist);
            },
          );
        },
      ),
    );
  }

  Widget search_icon() {
    return !searchStatus
        ? Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  searchStatus = true;
                });
              },
              child: const Icon(
                Icons.search,
                size: 26.0,
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  searchStatus = false;
                });
              },
              child: const Icon(
                Icons.close,
                size: 26.0,
              ),
            ),
          );
  }

  Widget search_field() {
    return TextField(
      controller: searchKeyword,
      autofocus: true,
      cursorColor: Colors.white,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
      ),
      textInputAction: TextInputAction.search,
      onChanged: (value) => filterPlaylist(value),
      decoration: const InputDecoration(
        hintText: 'Enter to Search',
        hintStyle: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 20,
        ),
      ),
    );
  }
}
