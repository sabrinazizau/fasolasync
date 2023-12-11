import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fasolasync/models/song_model.dart';
import '../config.dart';
import '../models/playlist_model.dart';
import '../restapi.dart';

// Assuming you have the PlaylistDetail widget as mentioned earlier
import '../screens/playlist_detail.dart';

class ListSong extends StatefulWidget {
  const ListSong({Key? key}) : super(key: key);

  @override
  ListSongState createState() => ListSongState();
}

class ListSongState extends State<ListSong> {
  final searchKeyword = TextEditingController();
  bool searchStatus = false;

  DataService ds = DataService();

  List data = [];
  List<SongsModel> songs = [];
  List<PlaylistModel> playlist = [];

  List<SongsModel> search_data = [];
  List<SongsModel> search_data_pre = [];

  selectAllSong() async {
    data = jsonDecode(await ds.selectAll(token, project, 'songs', appid));

    songs = data.map((e) => SongsModel.fromJson(e)).toList();

    setState(() {
      songs = songs;
    });
  }

  selectIdPlaylist(String id) async {
    List data = [];
    data = jsonDecode(await ds.selectId(token, project, 'playlist', appid, id));

    if (data.isNotEmpty) {
      playlist = data.map((e) => PlaylistModel.fromJson(e)).toList();
    }
  }

  selectIdSong(String id) async {
    List data = [];
    data = jsonDecode(await ds.selectId(token, project, 'songs', appid, id));

    if (data.isNotEmpty) {
      songs = data.map((e) => SongsModel.fromJson(e)).toList();
    }
  }

  void filterSong(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      search_data = data.map((e) => SongsModel.fromJson(e)).toList();
    } else {
      search_data_pre = data.map((e) => SongsModel.fromJson(e)).toList();
      search_data = search_data_pre
          .where((user) =>
              user.title.toLowerCase().contains(enteredKeyword.toLowerCase()) ||
              user.artist.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    //Refresh the UI
    setState(() {
      songs = search_data;
    });
  }

  Future reloadDataSong(dynamic value) async {
    setState(() {
      selectAllSong();
    });
  }

  @override
  void initState() {
    selectAllSong();

    super.initState();
  }

  // Future<void> addSongToPlaylist(String songId, String playlistId) async {
  //   try {
  //     // Fetch the existing playlist data
  //     List playlistData = jsonDecode(
  //         await ds.selectId(token, project, 'playlist', appid, playlistId));

  //     if (playlistData.isNotEmpty) {
  //       // Get the playlist model
  //       PlaylistModel playlistModel =
  //           PlaylistModel.fromJson(playlistData.first);

  //       // Update the playlist with the new song
  //       playlistModel.song_ids.add(songId);

  //       // Convert the updated playlist model back to JSON
  //       String updatedPlaylistJson = jsonEncode(playlistModel.toJson());

  //       // Update the playlist in the database
  //       await ds.updateId('songs', updatedPlaylistJson, token, project,
  //           'playlist', appid, playlistId);

  //       // Show a success message or perform additional actions if needed
  //       print('Song added to the playlist successfully.');
  //     }
  //   } catch (e) {
  //     // Handle errors, display an error message, or log the error
  //     print('Error adding song to the playlist: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as List<String>;

    return Scaffold(
      appBar: AppBar(
        title: !searchStatus ? const Text("Playlist List") : search_field(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, 'playlist_form_add')
                    .then(reloadDataSong);
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
      body: FutureBuilder<dynamic>(
        future: selectIdPlaylist(args[0]),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}',
                style: const TextStyle(color: Colors.red));
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      final item = songs[index];

                      return ListTile(
                        title: Text(item.title),
                        subtitle: Text(item.artist),
                        onTap: () {
                          Navigator.pushNamed(context, 'song_play',
                              arguments: [item.id]).then(reloadDataSong);
                        },
                        trailing: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue[900],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              // Call the method to add the song to the playlist
                              // addSongToPlaylist(item.id, args[0]);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
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
      onChanged: (value) => filterSong(value),
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
