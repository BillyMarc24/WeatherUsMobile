import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'weather.dart';

final storage = new FlutterSecureStorage();

class FavoriteScreen extends StatefulWidget {
  static const routeName = '/favorite';
  _FavoriteScreen createState() => _FavoriteScreen();
}

class _FavoriteScreen extends State<FavoriteScreen> {
  List favList = [];
  var load = 1;
  @override
  void initState() {
    getFavorite();
    super.initState();
  }

  @override
  final cityController = TextEditingController();
  Widget build(BuildContext context) {
    if (load == 1) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (favList.isEmpty) {
      return Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        'https://wallpaperaccess.com/full/3969418.jpg'),
                    fit: BoxFit.fill),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 100, left: 50),
                    child: Column(
                      children: [
                        Text(
                          'Anda belum memiliki lokasi favorit',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        'https://wallpaperaccess.com/full/3969418.jpg'),
                    fit: BoxFit.fill),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: favList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 255, 255)),
                          child: ListTile(
                              leading: const Icon(Icons.location_pin),
                              title: Text(favList[index]['kota'])),
                        ),
                        onTap: () async {
                          await storage.write(
                              key: "fid", value: "${favList[index]['id']}");
                          await storage.write(
                              key: "dCity", value: "${favList[index]['kota']}");
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (ctx) => Weather()));
                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider(
                        color: Colors.transparent,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  void getFavorite() async {
    var jwt = await storage.read(key: "jwt");
    final url = Uri.parse('https://cuaca-kita.herokuapp.com/api/favorite/all');
    final response = await http.get(url, headers: {"Authorization": "$jwt"});
    Map resultBody = json.decode(response.body);
    if (resultBody['success'] == true) {
      setState(() {
        load = 0;
        favList = resultBody['data'];
      });
    }
  }
}
