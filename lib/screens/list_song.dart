import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../config.dart';
import '../models/playlist_model.dart';
import '../restapi.dart';
import 'playlist_detail.dart';

class ListSong extends StatefulWidget {
  const ListSong({Key? key}) : super(key: key);

  @override
  ListSongState createState() => ListSongState();
}

class ListSongState extends State<ListSong> {
  late AudioPlayer audioPlayer;
  bool isPlaying = false;
  int currentlyPlayingIndex = -1;

  final searchKeyword = TextEditingController();
  bool searchStatus = false;
  DataService ds = DataService();
  List data = [];
  List<SongsModel> songs = [];
  List<SongsModel> songsPlaylist = [];
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

    // Refresh the UI
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
    audioPlayer = AudioPlayer();
  }

  Future<void> addSongToPlaylist(
      List<String> songIds, String playlistId) async {
    try {
      // Fetch the existing playlist data
      List playlistData = jsonDecode(
          await ds.selectId(token, project, 'playlist', appid, playlistId));

      if (playlistData.isNotEmpty) {
        // Get the playlist model
        PlaylistModel playlistModel =
            PlaylistModel.fromJson(playlistData.first);

        // Update the playlist with the new song
        playlistModel.song_ids.addAll(songIds);
        // Convert the updated playlist model back to JSON
        String updatedPlaylistJson = jsonEncode(playlistModel.song_ids);

        // Update the playlist in the database
        await ds.updateId('song_id', updatedPlaylistJson, token, project,
            'playlist', appid, playlistId);

        // Show a success message or perform additional actions if needed
        print('Song added to the playlist successfully.');
      }
    } catch (e) {
      // Handle errors, display an error message, or log the error
      print('Error adding song to the playlist: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as List<String>;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4A55A2)),
        ),
        title: !searchStatus
            ? const Text(
                "Playlist List",
                style: TextStyle(
                    color: Color(0xFF4A55A2), fontWeight: FontWeight.bold),
              )
            : search_field(),
        backgroundColor: Colors.white,
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
            return Container(
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
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: songs.length,
                  itemBuilder: (context, index) {
                    final item = songs[index];

                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      margin: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        title: Text(
                          item.title,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        subtitle: Text(
                          item.artist,
                          style: TextStyle(color: Colors.black, fontSize: 12),
                        ),
                        leading: IconButton(
                          icon: Icon(
                            isPlaying && currentlyPlayingIndex == index
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Color(0xFF4A55A2),
                          ),
                          onPressed: () {
                            handlePlayPause(index);
                          },
                        ),
                        // onTap: () {
                        //   Navigator.pushNamed(context, 'song_play',
                        //       arguments: [item.id]).then(reloadDataSong);
                        // },
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
                              List<String> songIdsToAdd =
                                  songs.map((song) => song.id).toList();
                              // Call the method to add the song to the playlist
                              addSongToPlaylist(songIdsToAdd, args[0]);
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
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
                color: Color(0xFF4A55A2),
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

  Widget buildPlayPauseButton(int index) {
    return IconButton(
      icon: Icon(
        isPlaying && currentlyPlayingIndex == index
            ? Icons.pause
            : Icons.play_arrow,
        color: Colors.white,
      ),
      onPressed: () {
        handlePlayPause(index);
      },
    );
  }

  void handlePlayPause(int index) async {
    if (audioPlayer.playing) {
      await audioPlayer.stop();
      setState(() {
        isPlaying = false;
      });
    } else {
      String songUrl = songs[index].url_song;
      String encodedUrl = Uri.encodeFull(songUrl);

      try {
        await audioPlayer.setUrl(encodedUrl);
        await audioPlayer.play();
        setState(() {
          isPlaying = true;
          currentlyPlayingIndex = index;
        });

        audioPlayer.playerStateStream.listen((playerState) {
          if (playerState.processingState == ProcessingState.completed) {
            setState(() {
              isPlaying = false;
            });
          }
        });
      } catch (e) {
        print('Error playing the song: $e');
        setState(() {
          isPlaying = false;
        });
      }
    }
    // Stop the currently playing song if any
    // String songUrl = songs[index].url_song;
    // print('Playing song from URL: $songUrl');

    // String encodedUrl = Uri.encodeFull(songUrl);
    // if (!isPlaying) {
    //   isPlaying = true;

    //   audioPlayer.play(UrlSource(encodedUrl));
    //   audioPlayer.onPlayerComplete.listen((event) {
    //     setState(() {
    //       isPlaying = false;
    //     });
    //   });
    // } else {
    //   audioPlayer.pause();
    //   isPlaying = false;
    // }
    // setState(() {});

    // Check if the URL is valid
    // if (encodedUrl.isNotEmpty) {
    //   await audioPlayer.play(UrlSource(encodedUrl));

    //   setState(() {
    //     isPlaying = true;
    //     currentlyPlayingIndex = index;
    //   });

    //   audioPlayer.onPlayerComplete.listen((event) {
    //     setState(() {
    //       isPlaying = false;
    //     });
    //   });
    // } else {
    //   // Handle invalid URL
    //   print('Invalid song URL');
    // }
  }
}
