import 'dart:convert';
import 'package:flutter/material.dart';
import '../config.dart';
import '../models/playlist_model.dart';
import '../restapi.dart';

class libraryPage extends StatefulWidget {
  const libraryPage({Key? key});

  @override
  libraryPageState createState() => libraryPageState();
}

class libraryPageState extends State<libraryPage> {
  final searchKeyword = TextEditingController();
  bool searchStatus = false;

  DataService ds = DataService();

  List data = [];
  List<PlaylistModel> playlist = [];

  List<PlaylistModel> search_data = [];
  List<PlaylistModel> search_data_pre = [];

  Future<void> selectAllPlaylist() async {
    data = jsonDecode(await ds.selectAll(token, project, 'playlist', appid));
    setState(() {
      playlist = data.map((e) => PlaylistModel.fromJson(e)).toList();
    });
  }

  Future reloadDataPlaylist(dynamic value) async {
    setState(() {
      selectAllPlaylist();
    });
  }

  @override
  void initState() {
    selectAllPlaylist();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(75.0),
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
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.library_music,
                          color: Colors.black,
                          size: 45,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'YOUR LIBRARY',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 35,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            height: 3,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, 'add_playlist_lib'),
                          icon: const Icon(Icons.add,
                              color: Colors.black, size: 35),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: searchKeyword,
                      decoration: InputDecoration(
                        hintText: 'Search for library ...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {},
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Playlists',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        height: 3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Divider(
                      color: Colors.black,
                      thickness: 1.5,
                      height: 2,
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: playlist.isEmpty
                          ? Center(
                              child: Text(
                                'No playlists in your library',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.all(20.0),
                              child: ListView.builder(
                                itemCount: playlist.length,
                                itemBuilder: (context, index) {
                                  final item = playlist[index];
                                  return Card(
                                    child: ListTile(
                                      leading: _buildAlbumImage(
                                        item.playlist_image,
                                        screenWidth,
                                      ),
                                      //tileColor: Colors.transparent,
                                      title: Text(
                                        item.playlist_name + ' - X Songs',
                                        style: TextStyle(fontSize: 30),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumImage(String? coverImage, double screenWidth) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    if (coverImage != null && coverImage.isNotEmpty) {
      return Container(
        width: screenWidth / 4,
        height: screenWidth / 4,
        //color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            fileUri + coverImage,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: screenWidth / 4,
        height: screenWidth / 4,
        decoration: BoxDecoration(
          color: Color(0xFF4A55A2),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Center(
          child: Icon(
            Icons.music_note,
            size: 50 * textScaleFactor,
            color: Colors.white,
          ),
        ),
      );
    }
  }
}
