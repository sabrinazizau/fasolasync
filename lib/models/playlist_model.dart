class PlaylistModel {
  final String id;
  final String playlist_name;
  final String playlist_image;
  final String playlist_desc;
  final String song_id;

  PlaylistModel(
      {required this.id,
      required this.playlist_name,
      required this.playlist_image,
      required this.playlist_desc,
      required this.song_id});

  factory PlaylistModel.fromJson(Map<String, dynamic> data) {
    return PlaylistModel(
        id: data['_id'],
        playlist_name: data['playlist_name'],
        playlist_image: data['playlist_image'],
        playlist_desc: data['playlist_desc'],
        song_id: data['song_id']);
  }
}
