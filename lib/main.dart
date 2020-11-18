import 'package:flutter/material.dart';

import './widgets/navbar.dart';
import './pages/bookshelf.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'PassionFruit', home: Page());
  }
}

class Page extends StatefulWidget {
  @override
  _PageState createState() => _PageState();
}

class _PageState extends State<Page> {
  int _pageIndex = 0;
  // static const TextStyle navText = TextStyle(
  //   color: Color(MAIN_ACCENT_COLOR),
  //   fontSize: 30,
  //   fontWeight: FontWeight.bold
  // );

  List<Widget> _pages = <Widget>[
    Text('Index 0: Settings'),
    BookShelfPage(),
    Text('Index 2: Search'),
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
        home: Scaffold(
            // * PAGE
            body: Center(
              child: _pages.elementAt(_pageIndex),
            ),

            // * NAV BAR
            bottomNavigationBar: NavBar(_pageIndex, _onNavBarTapped)));
  }
}
