import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weatherus/Utilities/colors.dart';
import 'package:intl/intl.dart';
import 'package:instant/instant.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = new FlutterSecureStorage();

class Weather extends StatefulWidget {
  static const routeName = '/weather-screen';
  const Weather({Key? key}) : super(key: key);

  @override
  State<Weather> createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  String idx = "";
  String city = "";
  String lata = "";
  String lnga = "";
  var load = 0;
  String favText = "Add Favorite";
  Map weatherList = {};

  @override
  void initState() {
    getWeatherData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (weatherList.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (load == 1) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: buildBackGroundColorGradient(
                weatherList['current']['temp'] - 273.15.round(),
                weatherList['current']['weather'][0]['main']),
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: buildAppBarWidget(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 5.0,
              ),
              Text(
                "$city",
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w400,
                  color: buildTextColor(
                      weatherList['current']['temp'] - 273.15.round(),
                      weatherList['current']['weather'][0]['main']),
                ),
              ),
              Image.network(
                  "http://openweathermap.org/img/wn/${weatherList['current']['weather'][0]['icon']}@2x.png",
                  width: MediaQuery.of(context).size.width / 3),
              const SizedBox(
                height: 1.0,
              ),
              Text(
                "${double.parse("${weatherList['current']['temp'] - 273.15}").round().toString()}°C",
                style: TextStyle(
                  fontSize: 70.0,
                  fontWeight: FontWeight.w300,
                  color: buildTextColor(
                      weatherList['current']['temp'] - 273.15.round(),
                      weatherList['current']['weather'][0]['main']),
                ),
              ),
              Text(
                "${weatherList['current']['weather'][0]['description']}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w300,
                  color: buildTextColor(
                      weatherList['current']['temp'] - 273.15.round(),
                      weatherList['current']['weather'][0]['main']),
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: weatherList['daily'].length - 3,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            buildWeatherListText(
                                weatherList['timezone_offset'].toDouble(),
                                weatherList['daily'][index + 1]['dt']),
                            style: TextStyle(
                              color: buildTextColor(
                                  weatherList['current']['temp'] -
                                      273.15.round(),
                                  weatherList['current']['weather'][0]['main']),
                              fontSize: 20.0,
                            ),
                          ),
                          Image.network(
                            "http://openweathermap.org/img/wn/${weatherList['daily'][index + 1]['weather'][0]['icon']}@2x.png",
                            height: 50,
                          ),
                          Row(
                            children: [
                              Text(
                                "${double.parse("${weatherList['daily'][index + 1]['temp']['min'] - 273.15}").round()}°",
                                style: TextStyle(
                                  color: buildTextColor(
                                      weatherList['current']['temp'] -
                                          273.15.round(),
                                      weatherList['current']['weather'][0]
                                          ['main']),
                                  fontSize: 22.0,
                                ),
                              ),
                              const SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                "${double.parse("${weatherList['daily'][index + 1]['temp']['max'] - 273.15}").round()}°",
                                style: TextStyle(
                                  color: buildTextColor(
                                      weatherList['current']['temp'] -
                                          273.15.round(),
                                      weatherList['current']['weather'][0]
                                          ['main']),
                                  fontSize: 22.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
        ),
      );
    }
  }

  List<Color> buildBackGroundColorGradient(weather, String weathers) {
    if (weather < 0 || weathers == "Snow") {
      return [niceWhite, niceDarkBlue];
    } else if (weather < 20 || weathers == "Rain") {
      return [niceVeryDarkBlue, niceDarkBlue];
    } else {
      return [niceRed, niceOrange];
    }
  }

  Color buildTextColor(weather, String weathers) {
    if (weather < 0 || weathers == "Snow") {
      return Colors.white;
    } else if (weather < 20 || weathers == "Rain") {
      return Colors.white;
    } else {
      return Colors.white;
    }
  }

  void getWeatherData() async {
    String body = "";
    var cityx = await storage.read(key: "dCity");
    var jwt = await storage.read(key: "jwt");
    var lat = await storage.read(key: "dLat");
    var id = await storage.read(key: "fid");
    var long = await storage.read(key: "dLng");
    if (id == null) {
      body = 'lat=$lat&long=$long';
      lata = lat!;
      lnga = long!;
    } else {
      body = 'id=$id';
      favText = "Remove Favorite";
      idx = id;
    }

    await storage.delete(key: "dCity");
    await storage.delete(key: "dLat");
    await storage.delete(key: "fid");
    await storage.delete(key: "dLng");
    final url = Uri.parse('https://cuaca-kita.herokuapp.com/api/ramalan');
    final response = await http.post(url, body: '$body', headers: {
      "Authorization": "$jwt",
      "Content-type": "application/x-www-form-urlencoded"
    });
    Map resultBody = json.decode(response.body);
    if (resultBody['success'] == true) {
      setState(() {
        city = cityx!;
        lata = "${resultBody['data']['lat']}";
        lnga = "${resultBody['data']['lon']}";
        weatherList = resultBody['data'];
      });
    }
  }

  AppBar buildAppBarWidget() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            buildWeatherListText(weatherList['timezone_offset'].toDouble(),
                weatherList['current']['dt']),
            style: TextStyle(
              fontSize: 16.0,
              color: buildTextColor(
                  weatherList['current']['temp'] - 273.15.round(),
                  weatherList['current']['weather'][0]['main']),
            ),
          ),
          Text(
            buildWeatherListTextD(weatherList['timezone_offset'].toDouble(),
                weatherList['current']['dt']),
            style: TextStyle(
              fontSize: 16.0,
              color: buildTextColor(
                  weatherList['current']['temp'] - 273.15.round(),
                  weatherList['current']['weather'][0]['main']),
            ),
          ),
        ],
      ),
      actions: [
        InkWell(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: buildTextColor(
                        weatherList['current']['temp'] - 273.15.round(),
                        weatherList['current']['weather'][0]['main']),
                  ),
                  Text(
                    favText,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: buildTextColor(
                          weatherList['current']['temp'] - 273.15.round(),
                          weatherList['current']['weather'][0]['main']),
                    ),
                  )
                ],
              ),
            ],
          ),
          onTap: () async {
            setState(() {
              load = 1;
            });
            var jwt = await storage.read(key: "jwt");
            if (idx.isEmpty) {
              var body = 'lat=$lata&long=$lnga&kota=$city';

              final url = Uri.parse(
                  "https://cuaca-kita.herokuapp.com/api/favorite/add");
              final response = await http.put(url, body: '$body', headers: {
                "Authorization": "$jwt",
                "Content-type": "application/x-www-form-urlencoded"
              });
              Map resultBody = json.decode(response.body);

              setState(() {
                favText = "Remove Favorite";
                idx = "${resultBody['id']}";
              });
            } else {
              final url = Uri.parse(
                  "https://cuaca-kita.herokuapp.com/api/favorite/$idx");
              await http.delete(url, headers: {
                "Authorization": "$jwt",
                "Content-type": "application/x-www-form-urlencoded"
              });
              setState(() {
                favText = "Add Favorite";
                idx = "";
              });
            }
            setState(() {
              load = 0;
            });
          },
        ),
        const SizedBox(
          width: 15.0,
        ),
      ],
    );
  }

  String buildWeatherListText(offset, day) {
    offset = (offset - 25200) / 3600;
    var date = new DateTime.fromMillisecondsSinceEpoch(day * 1000);
    DateTime converted = dateTimeToOffset(offset: offset, datetime: date);
    return DateFormat("EEEE").format(converted);
  }

  String buildWeatherListTextD(offset, day) {
    offset = (offset - 25200) / 3600;
    var date = new DateTime.fromMillisecondsSinceEpoch(day * 1000);
    DateTime converted = dateTimeToOffset(offset: offset, datetime: date);
    return DateFormat("dd-MM-yyy").format(converted);
  }
}
