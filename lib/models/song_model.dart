class SongsModel {
  final String id;
  final String title;
  final String artist;
  final String url_song;

  SongsModel(
      {required this.id,
      required this.title,
      required this.artist,
      required this.url_song});

  factory SongsModel.fromJson(Map<String, dynamic> data) {
    return SongsModel(
        id: data['_id'],
        title: data['title'],
        artist: data['artist'],
        url_song: data['url_song']);
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'artist': artist,
      'url_song': url_song,
    };
  }
}
