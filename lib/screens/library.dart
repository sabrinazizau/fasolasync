import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: Image.asset(
                    'assets/playlist1.jpeg',
                    width: 300,
                    height: 300,
                  ),
                ),
                SizedBox(width: 30),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 120.0),
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Playlist',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'random part ii',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 100),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SizedBox(height: 5),
                            Text('sabrinazizau • 1122 like • 64 songs, ',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text('about 3 hr 45 min',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Divider(
              color: Colors.black,
              thickness: 0.5,
            ),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue[900],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {},
                  ),
                ),
                SizedBox(width: 15),
                IconButton(
                  icon: Icon(
                    Icons.more_horiz,
                    color: Colors.grey[700],
                    size: 35,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 5),
            Expanded(
              child: ListView(
                children: [
                  DataTable(
                    columns: [
                      DataColumn(
                        label: Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: Text('#'),
                        ),
                      ),
                      DataColumn(label: Text('Title')),
                      DataColumn(label: Text('Album')),
                      DataColumn(label: Text('Date added')),
                      DataColumn(label: Text('Duration')),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(
                          Padding(
                            padding: EdgeInsets.only(right: 20.0),
                            child: Text('1'),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              Icon(Icons.music_note),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text('Remedi',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  Text('Tulus', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text('Manusia')),
                        DataCell(Text('Jul 31, 2023')),
                        DataCell(
                          Row(
                            children: [
                              Text('3:30'),
                              SizedBox(width: 80),
                              Icon(Icons.favorite, color: Colors.green[400]),
                            ],
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('2')),
                        DataCell(
                          Row(
                            children: [
                              Icon(Icons.music_note),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text('Kepada Noor',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  Text('Panji Sakti',
                                      style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text('Tanpa Aku')),
                        DataCell(Text('Jul 31, 2023')),
                        DataCell(
                          Row(
                            children: [
                              Text('4:09'),
                              SizedBox(width: 80),
                              Icon(Icons.favorite, color: Colors.green[400]),
                            ],
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('3')),
                        DataCell(
                          Row(
                            children: [
                              Icon(Icons.music_note),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text('Sepatu',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  Text('Tulus', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text('Gajah')),
                        DataCell(Text('Jul 31, 2023')),
                        DataCell(Text('3:39')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('4')),
                        DataCell(
                          Row(
                            children: [
                              Icon(Icons.music_note),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text('Bunga Tidur',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  Text('Tulus', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text('Gajah')),
                        DataCell(Text('Jul 31, 2023')),
                        DataCell(
                          Row(
                            children: [
                              Text('3:39'),
                              SizedBox(width: 80),
                              Icon(Icons.favorite, color: Colors.green[400]),
                            ],
                          ),
                        ),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('5')),
                        DataCell(
                          Row(
                            children: [
                              Icon(Icons.music_note),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text('Ruang Sendiri',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  Text('Tulus', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text('Monokrom')),
                        DataCell(Text('Jul 31, 2023')),
                        DataCell(Text('4:29')),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
