class PlaylistSongModel {
  final String id;
  final String playlist_id;
  final String song_id;
  final String title;
  final String artist;
  final String url_song;

  PlaylistSongModel({
    required this.id,
    required this.playlist_id,
    required this.song_id,
    required this.title,
    required this.artist,
    required this.url_song,
  });

  factory PlaylistSongModel.fromJson(Map<String, dynamic> data) {
    return PlaylistSongModel(
      id: data['_id'],
      playlist_id: data['playlist_id'],
      song_id: data['song_id'],
      title: data['title'],
      artist: data['artist'],
      url_song: data['url_song'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'playlist_id': playlist_id,
      'song_id': song_id,
      'title': title,
      'artist': artist,
      'url_song': url_song,
    };
  }
}
