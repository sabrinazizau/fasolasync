class AlbumModel {
  final String id;
  final String album_name;
  final String album_pict;
  final String album_year;

  AlbumModel(
      {required this.id,
      required this.album_name,
      required this.album_pict,
      required this.album_year});

  factory AlbumModel.fromJson(Map<String, dynamic> data) {
    return AlbumModel(
        id: data['_id'],
        album_name: data['album_name'],
        album_pict: data['album_pict'],
        album_year: data['album_year']);
  }
}
