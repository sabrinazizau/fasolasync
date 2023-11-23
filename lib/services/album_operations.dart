import 'package:flutter/material.dart';

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> popAlbums = [
      'assets/pop1.jpg',
      'assets/pop2.jpg',
      'assets/pop3.jpg',
      'assets/pop4.jpg',
      'assets/pop5.jpg',
      'assets/pop6.jpg',
      'assets/pop7.jpg',
    ];

    List<String> popAlbumNames = [
      'Pop Indonesia 00an',
      'Pop Biggest Hits',
      'Pop Indonesia 90an',
      'Mellow Pop Classics',
      'Fresh Indonesian Pop',
      'Accoustic Pop',
      'K-Pop Party Hits',
    ];

    List<String> indieAlbums = [
      'assets/indie1.jpg',
      'assets/indie2.jpg',
      'assets/indie3.jpg',
      'assets/indie4.jpg',
      'assets/indie5.jpg',
      'assets/indie6.jpg',
      'assets/indie7.jpg',
    ];

    List<String> indieAlbumNames = [
      'Sorai - Nadin',
      'Evaluasi - Hindia',
      'Aku Tenang - FourTwnty',
      'Mewangi - Banda Neira',
      'Usik - Feby Putri',
      'Berisik - Dere',
      'Belenggu - Amigdala',
    ];

    return Expanded(
      child: ListView(
        children: [
          _buildGenreSection('Pop', popAlbums, popAlbumNames, 7, 200, 200),
          _buildGenreSection(
              'Indie', indieAlbums, indieAlbumNames, 7, 200, 200),
        ],
      ),
    );
  }

  Widget _buildGenreSection(
      String genre,
      List<String> albumImages,
      List<String> albumNames,
      int itemsPerRow,
      double maxImageWidth,
      double maxImageHeight) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text(
            genre,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(itemsPerRow, (index) {
              String albumImage = albumImages[index % albumImages.length];
              String albumName = albumNames[index % albumNames.length];
              return _buildAlbumCard(
                  albumImage, albumName, maxImageWidth, maxImageHeight);
            }),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAlbumCard(String coverImage, String albumTitle,
      double maxImageWidth, double maxImageHeight) {
    return Container(
      width: maxImageWidth,
      child: Card(
        child: Column(
          children: [
            Image.asset(
              coverImage,
              width: maxImageWidth,
              height: maxImageHeight,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                albumTitle,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class AlbumDetail extends StatefulWidget {
//   const AlbumDetail({Key? key}) : super(key: key);

//   @override
//   _AlbumDetailState createState() => _AlbumDetailState();
// }

// class _AlbumDetailState extends State<AlbumDetail> {
//   DataService ds = DataService();

//   late ValueNotifier<int> _notifier;

//   List<AlbumModel> album = [];

//   @override
//   void initState() {
//     super.initState();
//     // Avoid calling async methods directly in initState
//     WidgetsBinding.instance?.addPostFrameCallback((_) async {
//       await selectIdAlbum();
//     });
//   }

//   Future<void> selectIdAlbum() async {
//     final args = ModalRoute.of(context)?.settings.arguments as List<String>;
//     String id = args[0];

//     List data =
//         jsonDecode(await ds.selectId(token, project, 'fasolasync', appid, id));
//     setState(() {
//       album = data.map((e) => AlbumModel.fromJson(e)).toList();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: ListView(
//         children: [
//           _buildGenreSection(
//             'Pop',
//             album.map((e) => e.album_pict).toList(),
//             album.map((e) => e.album_name).toList(),
//             7,
//             200,
//             200,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGenreSection(
//     String genre,
//     List<String> albumImages,
//     List<String> albumNames,
//     int itemsPerRow,
//     double maxImageWidth,
//     double maxImageHeight,
//   ) {
//     if (album.isEmpty) {
//       return CircularProgressIndicator(); // or another loading indicator
//     }

//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(18.0),
//           child: Text(
//             genre,
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: List.generate(itemsPerRow, (index) {
//               String albumImage = albumImages[index % albumImages.length];
//               String albumName = albumNames[index % albumNames.length];
//               return _buildAlbumCard(
//                   albumImage, albumName, maxImageWidth, maxImageHeight);
//             }),
//           ),
//         ),
//         SizedBox(height: 20),
//       ],
//     );
//   }

//   Widget _buildAlbumCard(String coverImage, String albumTitle,
//       double maxImageWidth, double maxImageHeight) {
//     return Container(
//       width: maxImageWidth,
//       child: Card(
//         child: Column(
//           children: [
//             Image.asset(
//               coverImage,
//               width: maxImageWidth,
//               height: maxImageHeight,
//               fit: BoxFit.cover,
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                 albumTitle,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
