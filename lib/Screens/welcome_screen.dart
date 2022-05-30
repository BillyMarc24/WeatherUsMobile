import 'package:flutter/material.dart';
import 'welcome.dart';
import 'about.dart';

class WelcomeScreen extends StatefulWidget {

  static const routeName = '/home';
  _WelcomeScreen createState() => _WelcomeScreen();

}

class _WelcomeScreen extends State<WelcomeScreen> {
  int _currentIndex = 0;
  final screens = [
    Welcome(),
    About(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedFontSize: 10,
      selectedIconTheme: IconThemeData(color: Colors.blue, size: 40),
      selectedItemColor: Colors.blue,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info_rounded),
          label: 'About',
        ),
      ],
      onTap: (index) {
        setState(()
        {
          _currentIndex = index;
        });
      },
    ),
    );
  }
}