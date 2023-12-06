import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tugas5/config.dart';
import 'package:tugas5/models/playlist_model.dart';
import 'package:tugas5/restapi.dart';

class libraryPage extends StatefulWidget {
  const libraryPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
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

  selectAllPlaylist() async {
    data = jsonDecode(await ds.selectAll(token, project, 'fasolasync', appid));

    playlist = data.map((e) => PlaylistModel.fromJson(e)).toList();

    setState(() {
      playlist = playlist;
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
    return Container(
      width: 685,
      height: 1211,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: Colors.white),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 685,
              height: 115,
              decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
            ),
          ),
          Positioned(
            left: 101,
            top: 29,
            child: SizedBox(
              width: 251,
              height: 57,
              child: Text(
                'FaSoLaSync',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  height: 0,
                ),
              ),
            ),
          ),
          Positioned(
            left: 99,
            top: 173,
            child: SizedBox(
              width: 469,
              height: 54,
              child: Text(
                'YOUR LIBRARY                       ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  height: 0,
                ),
              ),
            ),
          ),
          Positioned(
            left: 35,
            top: 392,
            child: Container(
              width: 612,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 35,
            top: 285,
            child: Container(
              width: 547,
              height: 46,
              decoration: BoxDecoration(color: Color(0xFFD9D9D9)),
            ),
          ),
          Positioned(
            left: 22,
            top: 356,
            child: SizedBox(
              width: 125,
              height: 36,
              child: Text(
                'Playlists',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  height: 0,
                ),
              ),
            ),
          ),
          Positioned(
            left: 197,
            top: 410,
            child: SizedBox(
              width: 293,
              height: 36,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Amigdala  ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                    TextSpan(
                      text: '⚫  ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                    TextSpan(
                      text: ' 1  Song',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            left: 31,
            top: 147,
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://via.placeholder.com/66x66"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Positioned(
            left: 57,
            top: 290,
            child: SizedBox(
              width: 341,
              height: 36,
              child: Text(
                'Search your library ...',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                  height: 0,
                ),
              ),
            ),
          ),
          Positioned(
            left: 35,
            top: 410,
            child: Container(
              width: 152,
              height: 152,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://via.placeholder.com/152x152"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Positioned(
            left: 197,
            top: 620,
            child: SizedBox(
              width: 293,
              height: 36,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Amigdala  ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                    TextSpan(
                      text: '⚫  ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                    TextSpan(
                      text: ' 1  Song',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            left: 35,
            top: 620,
            child: Container(
              width: 152,
              height: 152,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://via.placeholder.com/152x152"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Positioned(
            left: 197,
            top: 849,
            child: SizedBox(
              width: 293,
              height: 36,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Amigdala  ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                    TextSpan(
                      text: '⚫  ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                    TextSpan(
                      text: ' 1  Song',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            left: 35,
            top: 849,
            child: Container(
              width: 152,
              height: 152,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://via.placeholder.com/152x152"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Positioned(
            left: 193,
            top: 1059,
            child: SizedBox(
              width: 293,
              height: 36,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Amigdala  ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                    TextSpan(
                      text: '⚫  ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                    TextSpan(
                      text: ' 1  Song',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        height: 0,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            left: 31,
            top: 1059,
            child: Container(
              width: 152,
              height: 152,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage("https://via.placeholder.com/152x152"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
