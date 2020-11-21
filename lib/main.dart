import 'package:flutter/material.dart';
import 'package:PassionFruit/globals.dart';

import './widgets/navbar.dart';
import './pages/settings.dart';
import './pages/bookshelf.dart';
import './pages/search.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  void initUser() {
    // ! MOVE TO NEW USER PAGE
    writeUserFile({
      'settings': {
        'categories': {
          'People': true,
          'History': true,
          'Geography': true,
          'Arts': true,
          'Social Sciences': true,
          'Biology': true,
          'Physical Sciences': true,
          'Technology': true,
          'Mathematics': true,
        },
        'lesson-frequency': 5
      },
      'items': ['Basketball', 'LeBron James'],
      'preferences': {'list-view': true}
    });
  }

  @override
  Widget build(BuildContext context) {
    initUser();
    return MaterialApp(title: 'PassionFruit', home: Page());
  }
}

class Page extends StatefulWidget {
  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  int _pageIndex = 2;
  // static const TextStyle navText = TextStyle(
  //   color: Color(MAIN_ACCENT_COLOR),
  //   fontSize: 30,
  //   fontWeight: FontWeight.bold
  // );

  List<Widget> _pages = <Widget>[
    SettingsPage(),
    BookShelfPage(),
    SearchPage(),
  ];

  // Update page function
  void _onNavBarTapped(int i) {
    setState(() {
      _pageIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'PassionFruit',
        theme: ThemeData(
            primaryColor: Color(MAIN_COLOR),
            accentColor: Color(SECOND_ACCENT_COLOR),
            fontFamily: 'Roboto',
            textTheme: TextTheme(
              headline1: TextStyle(
                  fontSize: 36,
                  color: Color(MAIN_COLOR),
                  fontWeight: FontWeight.w500),
              headline2: TextStyle(
                  fontSize: 20,
                  color: Color(MAIN_COLOR),
                  fontWeight: FontWeight.w500),
              bodyText1: TextStyle(
                  fontSize: 14.0,
                  color: Color(TEXT_COLOR),
                  fontWeight: FontWeight.w300),
            )),
        home: Scaffold(
            // * PAGE
            body: Center(
              child: _pages.elementAt(_pageIndex),
            ),

            // * NAV BAR
            bottomNavigationBar: NavBar(_pageIndex, _onNavBarTapped)));
  }
}
