import 'dart:convert';
import 'package:fasolasync/models/playlistSong_model.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../config.dart';
import '../models/playlist_model.dart';
import '../restapi.dart';

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
  List<PlaylistModel> playlist = [];
  List<PlaylistSongModel> songsPlaylist = [];
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

  Future<void> addSongToPlaylist(String songId, String playlistId) async {
    try {
      // Fetch the existing playlist data
      List playlistData = jsonDecode(
          await ds.selectId(token, project, 'playlist', appid, playlistId));

      List songData =
          jsonDecode(await ds.selectId(token, project, 'songs', appid, songId));

      if (playlistData.isNotEmpty && songData.isNotEmpty) {
        String title = songData[0]['title'];
        String artist = songData[0]['artist'];
        String url_song = songData[0]['url_song'];

        PlaylistSongModel playlistSong = PlaylistSongModel(
          id: appid,
          playlist_id: playlistId,
          song_id: songId,
          title: title,
          artist: artist,
          url_song: url_song,
        );

        songsPlaylist.add(playlistSong);

        await ds.insertPlaylistSong(
          appid,
          playlistSong.playlist_id,
          playlistSong.song_id,
          playlistSong.title,
          playlistSong.artist,
          playlistSong.url_song,
        );

        showSuccessDialog();
        
        print('Song added to the playlist successfully.');
      }
    } catch (e) {
      // Handle errors, display an error message, or log the error
      print('Error adding song to the playlist: $e');
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Song added to the playlist successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
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
                              addSongToPlaylist(item.id, args[0]);
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
      bottomSheet: AudioControls(
          audioPlayer: audioPlayer,
          songs: songs,
          currentlyPlayingIndex: currentlyPlayingIndex,
          playNext: playNext,
          playPrevious: playPrevious),
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
    String songUrl = songs[index].url_song;
    String encodedUrl = Uri.encodeFull(songUrl);

    try {
      await audioPlayer.setUrl(encodedUrl);
      await audioPlayer.play();
      setState(() {
        isPlaying = true;
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
}

class AudioControls extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final List<SongsModel> songs;
  final int currentlyPlayingIndex;
  final VoidCallback playNext;
  final VoidCallback playPrevious;

  AudioControls({
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
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
