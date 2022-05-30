import 'package:flutter/material.dart';

class About extends StatelessWidget {
  static const routeName = '/about-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(
                      'https://cuaca-kita.herokuapp.com/assets/images/homebg.png'),
                  fit: BoxFit.fill),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60, left: 50),
                ),
              ),
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60, left: 50),
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
                        'Weather Us membantu pengguna untuk mencari kondisi cuaca di suatu daerah. Weather Us adalah Profesional yang sangat termotivasi yang telah diakui karena dukungannya untuk melayani pengguna.',
                        style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
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
  }
}
