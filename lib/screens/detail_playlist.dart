import 'dart:convert';
import 'dart:io';

import '../models/playlistSong_model.dart';
import '../screens/playlist_song.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

import '../models/playlist_model.dart';
import '../models/song_model.dart';
import '../config.dart';
import '../restapi.dart';

class DetailPlaylist extends StatefulWidget {
  const DetailPlaylist({Key? key}) : super(key: key);

  @override
  DetailPlaylistState createState() => DetailPlaylistState();
}

class DetailPlaylistState extends State<DetailPlaylist> {
  late AudioPlayer audioPlayer;
  late ValueNotifier<int> _notifier;

  bool isPlaying = false;
  int currentlyPlayingIndex = -1;
  String playlist_image = '-';
  DataService ds = DataService();

  List<PlaylistModel> playlist = [];
  List<SongsModel> songs = [];
  List<SongsModel> songsPlaylist = [];

  User? user = FirebaseAuth.instance.currentUser;

  void handlePlayPause(int index) async {
    if (audioPlayer.playing) {
      await audioPlayer.stop();
      setState(() {
        isPlaying = false;
        currentlyPlayingIndex = -1;
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
          currentlyPlayingIndex = -1;
        });
      }
    }
    setState(() {
      currentlyPlayingIndex = index;
    });
  }

  selectIdPlaylist(String id) async {
    List data = [];
    data = jsonDecode(await ds.selectId(token, project, 'playlist', appid, id));

    if (data.isNotEmpty) {
      playlist = data.map((e) => PlaylistModel.fromJson(e)).toList();
      playlist_image = playlist[0].playlist_image;
    }
  }

  selectSongsInPlaylist(String playlistId) async {
    List data = [];

    try {
      List<String> playlistIdList = [playlistId];

      data = jsonDecode(await ds.selectWhereIn(token, project, 'playlist',
          appid, 'song_id', playlistIdList.join('~')));

      // Lakukan sesuatu dengan data, misalnya, ubahnya menjadi objek model Lagu
      List<SongsModel> songsInPlaylist =
          data.map((e) => SongsModel.fromJson(e)).toList();

      // Lakukan sesuatu dengan daftar lagu yang telah diambil
      print('Songs in playlist: $songsInPlaylist');
    } catch (e) {
      // Tangani kesalahan
      print('Error fetching songs in playlist: $e');
    }
  }

  Future reloadDataPlaylist(dynamic value) async {
    setState(() {
      final args = ModalRoute.of(context)?.settings.arguments as List<String>;

      selectIdPlaylist(args[0]);
    });
  }

  Future reloadDataSong(dynamic value) async {
    setState(() {
      final args = ModalRoute.of(context)?.settings.arguments as List<String>;

      selectSongsInPlaylist(args[0]);
    });
  }

  @override
  void initState() {
    super.initState();
    _notifier = ValueNotifier<int>(0);
    audioPlayer = AudioPlayer();
  }

  Future pickImage(String id) async {
    try {
      var picked = await FilePicker.platform.pickFiles(withData: true);

      if (picked != null) {
        var response = await ds.upload(token, project,
            picked.files.first.bytes!, picked.files.first.extension.toString());

        var file = jsonDecode(response);

        await ds.updateId('playlist_image', file['file_name'], token, project,
            'playlist', appid, id);

        playlist_image = file['file_name'];

        // Trigger Change ValueNotifier
        _notifier.value++;
      }
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as List<String>;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: FutureBuilder<dynamic>(
        future: selectIdPlaylist(args[0]),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              {
                return const Text('none');
              }
            case ConnectionState.waiting:
              {
                return const Center(child: CircularProgressIndicator());
              }
            case ConnectionState.active:
              {
                return const Text('Active');
              }
            case ConnectionState.done:
              {
                if (snapshot.hasError) {
                  return Text('${snapshot.error}',
                      style: const TextStyle(color: Colors.red));
                } else {
                  return ListView(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFD6E6F2),
                              Color(0xFFA084DC),
                            ],
                          ),
                        ),
                        width: screenWidth,
                        height: screenHeight * 0.60,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      ValueListenableBuilder(
                                        valueListenable: _notifier,
                                        builder: (context, value, child) =>
                                            playlist_image == ''
                                                ? const Align(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Icon(
                                                      Icons.library_music,
                                                      color: Colors.black,
                                                      size: 300,
                                                    ),
                                                  )
                                                : Align(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 64.0),
                                                      child: FittedBox(
                                                        fit: BoxFit.cover,
                                                        child: Image.network(
                                                          fileUri +
                                                              playlist_image,
                                                          width: 300,
                                                          height: 300,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                      ),
                                      InkWell(
                                        onTap: () => pickImage(args[0]),
                                        child: Align(
                                          child: Container(
                                            height: 30.00,
                                            width: 30.00,
                                            margin: const EdgeInsets.only(
                                              right: 10.0,
                                              bottom: 10.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white70,
                                              borderRadius:
                                                  BorderRadius.circular(5.00),
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt_outlined,
                                              size: 20,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 80.0),
                                    alignment: Alignment.bottomLeft,
                                    child: Wrap(
                                      spacing: 8.0,
                                      children: [
                                        Text(
                                          'Playlist',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                playlist[0].playlist_name,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 80),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                playlist[0].playlist_desc,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      18, // Atur ukuran font sesuai kebutuhan
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              '${user!.displayName} • 64 songs ',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    18, // Atur ukuran font sesuai kebutuhan
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      AdditionalContentWidget(
                        onPressed: () {
                          Navigator.pushNamed(context, 'list_song',
                                  arguments: [playlist[0].id])
                              .then(reloadDataPlaylist);
                        },
                      ),
                      PlaylistSongsWidget(
                          playlistId: args[0],
                          audioPlayer: audioPlayer,
                          onPlayed: handlePlayPause),
                    ],
                  );
                }
              }
          }
        },
      ),
    );
  }
}

class AdditionalContentWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const AdditionalContentWidget({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(64.0),
      color: Color(0xFFA084DC),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Let's start building your playlist",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: onPressed,
              child: Text("Add to this playlist"),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

// }