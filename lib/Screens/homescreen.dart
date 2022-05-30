import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'weather.dart';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = new FlutterSecureStorage();

class HomeScreen extends StatefulWidget {
  static const routeName = '/home-screen';
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  final cityController = TextEditingController();
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  Timer? _deobunce;
  DetailsResult? cityName;
  @override
  void initState() {
    super.initState();
    String apiKey = 'AIzaSyDTpmRC-Wl7ccwvllDHwHT7_zLh076cTd4';
    googlePlace = GooglePlace(apiKey);
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.only(top: 50, left: 50),
                  child: Column(
                    children: [
                      Text(
                        'WeatherUS',
                        style: TextStyle(
                            fontSize: 55,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Text(
                        'Check your weather',
                        style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 25,
                child: Padding(
                  padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
                  child: Column(
                    children: [
                      Container(
                        height: 55,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.black)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 25.0, right: 25),
                          child: TextField(
                            controller: cityController,
                            autofocus: false,
                            style: TextStyle(fontSize: 24),
                            decoration: InputDecoration(
                                hintText: 'City',
                                hintStyle: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 24),
                                filled: true,
                                fillColor: Colors.white,
                                border: InputBorder.none,
                                suffixIcon: cityController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            cityController.text = "";
                                          });
                                        },
                                        icon: Icon(Icons.clear_outlined),
                                      )
                                    : null),
                            onChanged: (value) {
                              if (_deobunce?.isActive ?? false)
                                _deobunce!.cancel();
                              _deobunce =
                                  Timer(Duration(milliseconds: 500), () {
                                if (value.isNotEmpty) {
                                  autoCompleteSearch(value);
                                } else {}
                              });
                            },
                          ),
                        ),
                      ),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: predictions.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                child: Icon(
                                  Icons.pin_drop,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                predictions[index].description.toString(),
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                          // bottomLeft
                                          offset: Offset(-1, -1),
                                          color: Colors.black),
                                      Shadow(
                                          // bottomRight
                                          offset: Offset(1, -1),
                                          color: Colors.black),
                                      Shadow(
                                          // topRight
                                          offset: Offset(1, 1),
                                          color: Colors.black),
                                      Shadow(
                                          // topLeft
                                          offset: Offset(-1, 1),
                                          color: Colors.black),
                                    ]),
                              ),
                              onTap: () async {
                                final placeId = predictions[index].placeId!;
                                final details =
                                    await googlePlace.details.get(placeId);
                                if (details != null &&
                                    details.result != null &&
                                    mounted) {
                                  String lng = details
                                      .result!.geometry!.location!.lng
                                      .toString();
                                  String lat = details
                                      .result!.geometry!.location!.lat
                                      .toString();
                                  await storage.write(
                                      key: "dCity",
                                      value: details.result!.name!);
                                  await storage.write(key: "dLng", value: lng);
                                  await storage.write(key: "dLat", value: lat);
                                  setState(() {
                                    cityName = details.result;
                                    cityController.text = details.result!.name!;
                                    predictions = [];
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (ctx) => Weather()));
                                  });
                                }
                              },
                            );
                          })
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
