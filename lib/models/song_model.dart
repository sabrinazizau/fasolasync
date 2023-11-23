class SongsModel {
  final String id;
  final String title;
  final String artist;
  final String duration;

  SongsModel(
      {required this.id,
      required this.title,
      required this.artist,
      required this.duration});

  factory SongsModel.fromJson(Map<String, dynamic> data) {
    return SongsModel(
        id: data['_id'],
        title: data['title'],
        artist: data['artist'],
        duration: data['duration']);
  }
}
