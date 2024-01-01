import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../screens/playlist_song.dart';
import '../models/playlist_model.dart';
import '../models/playlist_song_model.dart';
import '../models/song_model.dart';
import '../config.dart';
import '../restapi.dart';

class PlaylistDetail extends StatefulWidget {
  const PlaylistDetail({Key? key}) : super(key: key);

  @override
  PlaylistDetailState createState() => PlaylistDetailState();
}

class PlaylistDetailState extends State<PlaylistDetail> {
  late AudioPlayer audioPlayer;
  late ValueNotifier<int> _notifier;
  bool showAdditionalContent = true;

  bool isPlaying = false;
  int currentlyPlayingIndex = -1;
  String playlist_image = '-';
  DataService ds = DataService();

  List<PlaylistModel> playlist = [];
  List<PlaylistSongModel> songs = [];
  List<SongsModel> songsPlaylist = [];

  User? user = FirebaseAuth.instance.currentUser;

  Future<List<PlaylistSongModel>> selectSongsInPlaylist(
      String playlistId) async {
    List<PlaylistSongModel> data = [];

    try {
      var response = await ds.selectWhere(
          token, project, 'playlist_song', appid, 'playlist_id', playlistId);
      data = jsonDecode(response)
          .map<PlaylistSongModel>((e) => PlaylistSongModel.fromJson(e))
          .toList();
      print(data);
    } catch (e) {
      print('error : $e');
    }

    return data;
  }

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

  Future<void> reloadAdditionalContent() async {
    final args = ModalRoute.of(context)?.settings.arguments as List<String>;
    List<PlaylistSongModel> updatedSongs = await selectSongsInPlaylist(args[0]);

    setState(() {
      songs = updatedSongs;
      showAdditionalContent = songs.isEmpty;
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFA084DC),
                Color(0xFFD6E6F2),
              ],
              begin: FractionalOffset.bottomCenter,
              end: FractionalOffset.topCenter,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
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
                      return FutureBuilder<List<PlaylistSongModel>>(
                        future: selectSongsInPlaylist(args[0]),
                        builder: (context,
                            AsyncSnapshot<List<PlaylistSongModel>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            List<PlaylistSongModel> song = snapshot.data!;
                            return SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            ValueListenableBuilder(
                                              valueListenable: _notifier,
                                              builder:
                                                  (context, value, child) =>
                                                      playlist_image == ''
                                                          ? const Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Expanded(
                                                                child: Icon(
                                                                  Icons
                                                                      .library_music,
                                                                  color: Colors
                                                                      .black,
                                                                  size: 200,
                                                                ),
                                                              ),
                                                            )
                                                          : Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Expanded(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              25,
                                                                          top:
                                                                              25),
                                                                  child:
                                                                      FittedBox(
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          screenWidth /
                                                                              5,
                                                                      height:
                                                                          screenWidth /
                                                                              5,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0), // Sesuaikan dengan kebutuhan
                                                                        image:
                                                                            DecorationImage(
                                                                          image:
                                                                              NetworkImage(fileUri + playlist_image),
                                                                          fit: BoxFit
                                                                              .contain,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    fit: BoxFit
                                                                        .contain,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                            ),
                                            InkWell(
                                              onTap: () => pickImage(args[0]),
                                              child: Align(
                                                // alignment: Alignment.bottomLeft,
                                                child: Expanded(
                                                  child: Container(
                                                    height: screenWidth / 25,
                                                    width: screenWidth / 25,
                                                    margin:
                                                        const EdgeInsets.only(
                                                      right: 10,
                                                      bottom: 10,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white70,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              screenHeight /
                                                                  30),
                                                    ),
                                                    child: Icon(
                                                      Icons.camera_alt_outlined,
                                                      size: screenWidth / 45,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: screenWidth / 50),
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                top: screenHeight / 30),
                                            padding: const EdgeInsets.all(8.0),
                                            alignment: Alignment.centerLeft,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Playlist',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize:
                                                          screenWidth / 50),
                                                ),
                                                SizedBox(
                                                  height: screenHeight / 60,
                                                ),
                                                Text(
                                                  playlist[0].playlist_name,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          screenWidth / 20),
                                                ),
                                                SizedBox(
                                                    height: screenHeight / 60),
                                                Text(
                                                  playlist[0].playlist_desc,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize:
                                                          screenWidth / 50),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      '${user!.displayName} • ${song.length} songs ',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: screenWidth /
                                                              50 // Atur ukuran font sesuai kebutuhan
                                                          ),
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            screenHeight / 50),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 40),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.black,
                                              size: screenHeight / 30,
                                            ),
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                context,
                                                'playlist_form_edit',
                                                arguments: [playlist[0].id],
                                              ).then(reloadDataPlaylist);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete_outline,
                                              size: screenHeight / 30,
                                              color: Colors.black,
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title:
                                                        const Text("Warning"),
                                                    content: const Text(
                                                        "Remove this data?"),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                            "CANCEL"),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: const Text(
                                                            "REMOVE"),
                                                        onPressed: () async {
                                                          bool response =
                                                              await ds.removeId(
                                                            token,
                                                            project,
                                                            'playlist',
                                                            appid,
                                                            args[0],
                                                          );

                                                          Navigator.of(context)
                                                              .pop();

                                                          if (response) {
                                                            Navigator.pop(
                                                                context, true);
                                                          }
                                                        },
                                                      )
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(thickness: 2),
                                    if (song.isNotEmpty)
                                      AddMoreSongs(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            'list_song',
                                            arguments: [playlist[0].id],
                                          ).then(reloadDataSong);
                                        },
                                      ),
                                    if (song.isNotEmpty)
                                      Container(
                                        child: PlaylistSongsWidget(
                                          playlistId: args[0],
                                          audioPlayer: audioPlayer,
                                          onPlayed: handlePlayPause,
                                          song: song,
                                          onAllDataDeleted:
                                              reloadAdditionalContent,
                                        ),
                                      )
                                    else if (showAdditionalContent)
                                      AdditionalContentWidget(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                                  context, 'list_song',
                                                  arguments: [playlist[0].id])
                                              .then(reloadDataSong);
                                        },
                                      )
                                    else
                                      Container(),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }
                  }
              }
            },
          ),
        ),
      ],
    );
  }
}

class AddMoreSongs extends StatelessWidget {
  final VoidCallback onPressed;

  const AddMoreSongs({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Spacer(),
                ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 16.0),
                    child: Text(
                      'Add more songs',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF4A55A2),
                    onPrimary: Color(0xFF4A55A2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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
