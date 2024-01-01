import 'dart:convert';

import 'package:fasolasync/models/playlistSong_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config.dart';
import '../restapi.dart';

class PlaylistSongsWidget extends StatefulWidget {
  final String playlistId;
  final AudioPlayer audioPlayer;
  final Function(int) onPlayed;
  final List<PlaylistSongModel> song;
  final VoidCallback onAllDataDeleted;

  const PlaylistSongsWidget(
      {Key? key,
      required this.playlistId,
      required this.audioPlayer,
      required this.onPlayed,
      required this.song,
      required this.onAllDataDeleted})
      : super(key: key);

  @override
  PlaylistSongState createState() => PlaylistSongState();
}

class PlaylistSongState extends State<PlaylistSongsWidget> {
  late AudioPlayer audioPlayer;
  DataService ds = DataService();
  bool isPlaying = false;
  int currentlyPlayingIndex = -1;
  List<PlaylistSongModel> songs = [];

  @override
  void initState() {
    super.initState();
    audioPlayer = widget.audioPlayer;
  }

  selectSongsInPlaylist(String playlistId) async {
    List data = [];

    try {
      data = jsonDecode(await ds.selectWhere(
          token, project, 'playlist_song', appid, 'playlist_id', playlistId));
      songs = data.map((e) => PlaylistSongModel.fromJson(e)).toList();
      print(songs);
    } catch (e) {
      print('error : $e');
    }

    return songs;
  }

  Future<void> reloadSong() async {
  final args = ModalRoute.of(context)?.settings.arguments as List<String>;

  try {
    List<PlaylistSongModel> updatedSongs = await selectSongsInPlaylist(args[0]);

    setState(() {
      songs = updatedSongs;
    });
  } catch (e) {
    print('Error reloading songs: $e');
  }
}

  void removePlaylist(String playlistId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(
              'Are you sure you want to remove the song from the playlist?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async{
                // Remove the song from the playlist
                ds.removeId(token, project, 'playlist_song', appid, playlistId);

                await reloadSong();

                widget.onAllDataDeleted();
                // Close the alert
                Navigator.of(context).pop();
              },
              child: Text('Yes, Remove'),
            ),
          ],
        );
      },
    );
  }

  void handlePlayPause(int index) async {
    if (widget.audioPlayer.playing) {
      await widget.audioPlayer.stop();
      setState(() {
        isPlaying = false;
        currentlyPlayingIndex = -1;
      });
    } else {
      String songUrl = songs[index].url_song;
      String encodedUrl = Uri.encodeFull(songUrl);

      try {
        await widget.audioPlayer.setUrl(encodedUrl);
        await widget.audioPlayer.play();
        setState(() {
          isPlaying = true;
          currentlyPlayingIndex = index;
        });

        widget.audioPlayer.playerStateStream.listen((playerState) {
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

    widget.onPlayed(index);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as List<String>;
    return FutureBuilder<dynamic>(
      future: selectSongsInPlaylist(args[0]),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Menampilkan lagu-lagu dalam playlist
          List<PlaylistSongModel> songsInPlaylist = songs;
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: songsInPlaylist.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                child: ListTile(
                  title: Text(
                    songsInPlaylist[index].title,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  subtitle: Text(
                    songsInPlaylist[index].artist,
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  leading: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: IconButton(
                      key: ValueKey<int>(currentlyPlayingIndex),
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
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      // Implement your logic to remove the playlist
                      removePlaylist(songsInPlaylist[index].id);
                    },
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
