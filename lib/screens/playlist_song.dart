import 'dart:convert';

import '../models/playlist_song_model.dart';
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
      List<PlaylistSongModel> updatedSongs =
          await selectSongsInPlaylist(args[0]);

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
              onPressed: () async {
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

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as List<String>;
    return FutureBuilder<dynamic>(
      future: selectSongsInPlaylist(args[0]),
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          // Menampilkan lagu-lagu dalam playlist
          List<PlaylistSongModel> songsInPlaylist = snapshot.data;

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
                        handlePlayPause(index, context);
                      },
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Color(0xFF4A55A2),
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

  void handlePlayPause(int index, BuildContext context) async {
    if (audioPlayer.playing) {
      await audioPlayer.pause(); // Pause the audio
      setState(() {
        isPlaying = false;
        currentlyPlayingIndex = -1;
      });
    } else {
      // If the audio is not playing, start playing the selected song
      playSong(index);

      // Show bottom sheet with AudioControl when play icon is clicked
      showBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return AudioControl(
            audioPlayer: audioPlayer,
            songs: songs,
            currentlyPlayingIndex: currentlyPlayingIndex,
            playNext: playNext,
            playPrevious: playPrevious,
          );
        },
      );
    }

    setState(() {
      currentlyPlayingIndex = index;
    });
  }

  void playNext() {
    if (currentlyPlayingIndex < songs.length - 1) {
      currentlyPlayingIndex++;
      playSong(currentlyPlayingIndex);
    }
  }

  void playPrevious() {
    if (currentlyPlayingIndex > 0) {
      currentlyPlayingIndex--;
      playSong(currentlyPlayingIndex);
    }
  }

  void playSong(int index) async {
    if (audioPlayer.playing && currentlyPlayingIndex == index) {
      // Jika lagu yang diputar adalah lagu yang sama, hentikan lagu
      await audioPlayer.stop();
      setState(() {
        isPlaying = false;
        currentlyPlayingIndex = -1;
      });
    } else {
      // Jika lagu yang diputar bukan lagu yang sama, putar lagu baru
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
              currentlyPlayingIndex = -1;
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
    // showBottomSheet(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return AudioControls(
    //       audioPlayer: audioPlayer,
    //       songs: songs,
    //       currentlyPlayingIndex: currentlyPlayingIndex,
    //       playNext: playNext,
    //       playPrevious: playPrevious,
    //     );
    //   },
    // );
    setState(() {
      currentlyPlayingIndex = index;
    });
  }
}

class AudioControl extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final List<PlaylistSongModel> songs;
  final int currentlyPlayingIndex;
  final VoidCallback playNext;
  final VoidCallback playPrevious;

  AudioControl({
    required this.audioPlayer,
    required this.songs,
    required this.currentlyPlayingIndex,
    required this.playNext,
    required this.playPrevious,
  });

  double sliderValue = 0.0;

  void seekTo(double value) {
    final duration = audioPlayer.duration;
    if (duration != null) {
      final position = duration * value;
      audioPlayer.seek(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: 200), // Adjust the maxHeight as needed
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[900],
                    radius: 25,
                    child: Icon(
                      Icons.music_note,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentlyPlayingIndex != -1
                            ? songs[currentlyPlayingIndex].title
                            : '',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        currentlyPlayingIndex != -1
                            ? songs[currentlyPlayingIndex].artist
                            : '',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              StreamBuilder<Duration?>(
                stream: audioPlayer.durationStream,
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: audioPlayer.positionStream,
                    builder: (context, snapshot) {
                      var position = snapshot.data ?? Duration.zero;
                      if (position > duration) {
                        position = duration;
                      }
                      sliderValue = duration.inMilliseconds > 0
                          ? position.inMilliseconds / duration.inMilliseconds
                          : 0.0;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Slider(
                            value: sliderValue,
                            onChanged: (value) {
                              seekTo(value);
                            },
                            min: 0.0,
                            max: 1.0,
                          ),
                          Row(
                            children: [
                              Text(
                                formatDuration(position),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '/',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Text(
                                formatDuration(duration),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous),
                    onPressed: () {
                      playPrevious();
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      audioPlayer.playing ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: () {
                      if (audioPlayer.playing) {
                        audioPlayer.pause();
                      } else {
                        audioPlayer.play();
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    onPressed: () {
                      playNext();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
