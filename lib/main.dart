import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weatherus/Screens/login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import './Screens/signup_screen.dart';
import './Screens/home.dart';
import './Screens/welcome_screen.dart';
import 'dart:convert';
import './Models/auth.dart';
import 'package:http/http.dart' as http;

const storage = FlutterSecureStorage();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Future<String> get jwtOrEmpty async {
    var jwt = await storage.read(key: "jwt");
    if (jwt == null) return "";
    final url = Uri.parse('https://cuaca-kita.herokuapp.com/api/me');
    var response = await http.get(url,
        headers: {"Authorization": "$jwt", "Content-type": "Application/json"});
    if (response.body == null) {
      storage.deleteAll();
      return "";
    }
    return response.body;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => Auth(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder(
            future: jwtOrEmpty,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              if (snapshot.data != "") {
                var str = json.decode(snapshot.data as String);
                if (str['success'] == true) {
                  return HomePage();
                } else {
                  return WelcomeScreen();
                }
              } else {
                return WelcomeScreen();
              }
            }),
        routes: {
          HomePage.routeName: (context) => HomePage(),
          WelcomeScreen.routeName: (context) => WelcomeScreen(),
          SignupScreen.routeName: (context) => SignupScreen(),
          LoginScreen.routeName: (context) => LoginScreen(),
        },
      ),
    );
  }
}
