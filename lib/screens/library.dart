import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../config.dart';
import '../models/playlist_model.dart';
import '../restapi.dart';

class libraryPage extends StatefulWidget {
  const libraryPage({Key? key});

  @override
  libraryPageState createState() => libraryPageState();
}

bool isUserLoggedIn() {
  User? user = FirebaseAuth.instance.currentUser;
  return user != null;
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

  void filterPlaylist(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      search_data = data.map((e) => PlaylistModel.fromJson(e)).toList();
    } else {
      search_data_pre = data.map((e) => PlaylistModel.fromJson(e)).toList();
      search_data = search_data_pre
          .where((user) => user.playlist_name
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    // Refresh the UI
    setState(() {
      playlist = search_data;
    });
  }

  Future reloadDataPlaylist(dynamic value) async {
    setState(() {
      selectAllPlaylist();
    });
  }

  @override
  void initState() {
    super.initState();

    if (isUserLoggedIn()) {
      selectAllPlaylist();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            padding: EdgeInsets.zero,
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
                              size: screenWidth > 600 ? 45 : 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'YOUR LIBRARY',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: screenWidth > 600 ? 35 : 20,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                height: 3,
                              ),
                            ),
                            const Spacer(),
                            if (isUserLoggedIn())
                              IconButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, 'playlist_form_add'),
                                icon: const Icon(Icons.add,
                                    color: Colors.black, size: 30),
                              ),
                          ],
                        ),
                        SizedBox(height: 5),
                        searchField(),
                        SizedBox(height: 15),
                        Text(
                          'Playlists',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth > 600 ? 20 : 15,
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
                        isUserLoggedIn()
                            ? Expanded(
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
                                          scrollDirection: Axis.vertical,
                                          itemCount: playlist.length,
                                          itemBuilder: (context, index) {
                                            final item = playlist[index];

                                            return InkWell(
                                              key: ValueKey(item.id),
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, 'playlist_detail',
                                                    arguments: [
                                                      item.id
                                                    ]).then((value) =>
                                                    selectAllPlaylist());
                                              },
                                              child: _buildAlbumCard(
                                                item.playlist_image ?? '',
                                                item.playlist_name,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                              )
                            : Center(
                                child: Text(
                                  'Please log in to view your playlists',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight:
                                        FontWeight.bold, // Make the text bold
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlbumCard(String? coverImage, String albumTitle) {
    final screenWidth = MediaQuery.of(context).size.width;
    //final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    return Card(
      color: Colors.transparent,
      child: Container(
        width: screenWidth,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (coverImage != null && coverImage.isNotEmpty)
              Image.network(
                fileUri + '$coverImage',
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 150,
                width: 150,
                color: Color(0xFF4A55A2),
                child: Center(
                  child: Icon(
                    Icons.music_note,
                    size: 60 * textScaleFactor,
                    color: Colors.white,
                  ),
                ),
              ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                //padding: const EdgeInsets.all(45.0),
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '$albumTitle' + ' • x songs',
                    style: TextStyle(
                      fontSize: 16 * textScaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchField() {
    return TextField(
      controller: searchKeyword,
      autofocus: true,
      cursorColor: Colors.black,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
      ),
      textInputAction: TextInputAction.search,
      onChanged: (value) {
        filterPlaylist(value);
      },
      decoration: InputDecoration(
        hintText: 'Search for library ...',
        prefixIcon: Icon(Icons.search),
        hintStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
      ),
    );
  }
}
