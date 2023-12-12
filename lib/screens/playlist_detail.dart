import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/playlist_model.dart';

import 'package:file_picker/file_picker.dart';
import '../models/song_model.dart';

import '../config.dart';
import '../restapi.dart';

class PlaylistDetail extends StatefulWidget {
  const PlaylistDetail({Key? key}) : super(key: key);

  @override
  _PlaylistDetailState createState() => _PlaylistDetailState();
}

class _PlaylistDetailState extends State<PlaylistDetail> {
  AudioPlayer audioPlayer = AudioPlayer();

  DataService ds = DataService();

  String playlist_image = '-';
  late ValueNotifier<int> _notifier;

  List<PlaylistModel> playlist = [];
  List<SongsModel> songs = [];

  List<SongsModel> songsPlaylist = [];

  selectIdPlaylist(String id) async {
    List data = [];
    data = jsonDecode(await ds.selectId(token, project, 'playlist', appid, id));

    if (data.isNotEmpty) {
      playlist = data.map((e) => PlaylistModel.fromJson(e)).toList();
      playlist_image = playlist[0].playlist_image;
    }
  }

  selectIdSong(String id) async {
    List data = [];
    data = jsonDecode(await ds.selectId(token, project, 'songs', appid, id));

    if (data.isNotEmpty) {
      songs = data.map((e) => SongsModel.fromJson(e)).toList();
    }
  }

  selectSong(String playlist_id) async {
    List data = [];

    data = jsonDecode(await ds.selectWhereIn(
        token, project, 'playlist', appid, 'song_id', playlist_id));

    if (data.isNotEmpty) {
      // List<String> songs_ids = data.map((e) => e['song_id'].toString()).toList();
      List<String> song_ids = List<String>.from(data.first['song_ids'] ?? []);

      List<Map<String, dynamic>> songsData = [];
      // List<List> songsData = [];

      for (String song_id in song_ids) {
        Map<String, dynamic> song = jsonDecode(await ds.selectWhereIn(
            token, project, 'songs', appid, '_id', song_id));
        songsData.add(song);
      }

      if (songsData.isNotEmpty) {
        songsPlaylist = songsData.map((e) => SongsModel.fromJson(e)).toList();
      }
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

      selectIdSong(args[0]);
    });
  }

  Future reloadDataSongInPlaylist(dynamic value) async {
    setState(() {
      final args = ModalRoute.of(context)?.settings.arguments as List<String>;

      selectSong(args[0]);
    });
  }

  File? image;
  String? imagePlaylist;

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

  int currentlyPlayingIndex = -1;
  bool isPlaying = false;

  void playPause(int index) async {
    if (currentlyPlayingIndex == index) {
      if (isPlaying) {
        audioPlayer.pause();
        setState(() {
          isPlaying = false;
        });
      } else {
        audioPlayer.resume();
        setState(() {
          isPlaying = true;
        });
      }
    } else {
      String songUrl = songsPlaylist[index].url_song;
      await audioPlayer.play(UrlSource(songUrl));

      setState(() {
        currentlyPlayingIndex = index;
        isPlaying = true;
      });
    }
  }

  void stop() {
    audioPlayer.stop();
    setState(() {
      currentlyPlayingIndex = -1;
      isPlaying = false;
    });
  }

  @override
  void initState() {
    // Init the value notifier
    _notifier = ValueNotifier<int>(0);
    super.initState();
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
        title: const Text(
          'Playlist Detail',
          style: TextStyle(color: Color(0xFF4A55A2)),
        ),
        backgroundColor: Colors.white,
      ),
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
                        padding: EdgeInsets.all(80.0),
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
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.60,
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                              'sabrinazizau • 1122 like • 64 songs, ',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    18, // Atur ukuran font sesuai kebutuhan
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              'about 3 hr 45 min',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                              ),
                                            ),
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
                      Container(
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignCenter,
                            ),
                          ),
                        ),
                      ),
                      // Row(
                      //   children: [
                      //     Container(
                      //       width: 0,
                      //       height: 60,
                      //       decoration: BoxDecoration(
                      //         shape: BoxShape.circle,
                      //         color: Colors.blue[900],
                      //       ),
                      //       child: IconButton(
                      //         icon: Icon(
                      //           Icons.play_arrow,
                      //           color: Colors.white,
                      //           size: 40,
                      //         ),
                      //         onPressed: () {},
                      //       ),
                      //     ),

                      Container(
                        padding: const EdgeInsets.all(16.0),
                        color: Color(0xFFA084DC),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 80),
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .end, // Align the children at the end of the row
                              children: [
                                Spacer(), // Use Spacer to push icons to the right
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      'playlist_form_edit',
                                      arguments: [playlist[0].id],
                                    ).then(reloadDataPlaylist);
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Warning"),
                                            content:
                                                const Text("Remove this data?"),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text("CANCEL"),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text("REMOVE"),
                                                onPressed: () async {
                                                  bool response =
                                                      await ds.removeId(
                                                    token,
                                                    project,
                                                    'playlist',
                                                    appid,
                                                    args[0],
                                                  );

                                                  Navigator.of(context).pop();

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
                                    child: Icon(
                                      Icons.delete_outline,
                                      size: 35.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 120),
                            Center(
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
                                    onPressed: () {
                                      Navigator.pushNamed(context, 'list_song',
                                              arguments: [playlist[0].id])
                                          .then(reloadDataPlaylist);
                                    },
                                    child: Text("Add to this playlist"),
                                  ),
                                  SizedBox(height: 100),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: songsPlaylist.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(songsPlaylist[index].title),
                              subtitle: Text(songsPlaylist[index].artist),
                              trailing: IconButton(
                                onPressed: () {
                                  playPause(index);
                                },
                                icon: Icon(
                                  currentlyPlayingIndex == index && isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
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
