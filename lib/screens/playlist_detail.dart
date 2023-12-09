import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tugas5/models/playlist_model.dart';

import 'package:file_picker/file_picker.dart';
import 'package:tugas5/models/song_model.dart';

import '../config.dart';
import '../restapi.dart';

class PlaylistDetail extends StatefulWidget {
  const PlaylistDetail({Key? key}) : super(key: key);

  @override
  _PlaylistDetailState createState() => _PlaylistDetailState();
}

class _PlaylistDetailState extends State<PlaylistDetail> {
  DataService ds = DataService();

  String playlist_image = '-';
  late ValueNotifier<int> _notifier;

  List<PlaylistModel> playlist = [];
  List<SongsModel> songs = [];

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
                        decoration: const BoxDecoration(color: Colors.blue),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.40,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                ValueListenableBuilder(
                                  valueListenable: _notifier,
                                  builder: (context, value, child) =>
                                      playlist_image == '-'
                                          ? const Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 130,
                                              ),
                                            )
                                          : Align(
                                              alignment: Alignment.bottomCenter,
                                              child: CircleAvatar(
                                                radius: 80,
                                                backgroundImage: NetworkImage(
                                                  fileUri + playlist_image,
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
                                        left: 183.00,
                                        top: 10.00,
                                        right: 113.00,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white70,
                                        borderRadius: BorderRadius.circular(
                                          5.00,
                                        ),
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
                            SizedBox(width: 30),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(top: 120.0),
                                alignment: Alignment.bottomLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                    Text(
                                      playlist[0].playlist_name,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 100),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(height: 5),
                                        Text(
                                            'sabrinazizau • 1122 like • 64 songs, ',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 5),
                                        Text('about 3 hr 45 min',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(height: 5),
                                        Text(
                                          playlist[0].playlist_desc,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 100),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Divider(
                        color: Colors.black,
                        thickness: 0.5,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue[900],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 40,
                              ),
                              onPressed: () {},
                            ),
                          ),
                          SizedBox(width: 15),
                          IconButton(
                            icon: Icon(
                              Icons.more_horiz,
                              color: Colors.grey[700],
                              size: 35,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Expanded(
                        child: ListView(
                          children: [
                            DataTable(
                              columns: [
                                DataColumn(
                                  label: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 4.0),
                                    child: Text('#'),
                                  ),
                                ),
                                DataColumn(label: Text('Title')),
                                DataColumn(label: Text('Duration')),
                              ],
                              rows: [
                                DataRow(cells: [
                                  DataCell(
                                    Padding(
                                      padding: EdgeInsets.only(right: 20.0),
                                      child: Text('1'),
                                    ),
                                  ),
                                  DataCell(
                                    songs.isNotEmpty
                                        ? Row(
                                            children: [
                                              Icon(Icons.music_note),
                                              SizedBox(width: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 5),
                                                  Text(songs[0].title ?? '',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  SizedBox(height: 5),
                                                  Text(songs[0].artist ?? '',
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                ],
                                              ),
                                            ],
                                          )
                                        : Text('No songs available'),
                                  ),
                                  DataCell(
                                    songs.isEmpty
                                        ? Row(
                                            children: [
                                              Text(songs[0].duration ?? ''),
                                              SizedBox(width: 80),
                                              Icon(Icons.favorite,
                                                  color: Colors.green[400]),
                                            ],
                                          )
                                        : Text(''),
                                  ),
                                ]),
                              ],
                            ),
                          ],
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
