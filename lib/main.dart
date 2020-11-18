import 'package:flutter/material.dart';
import './globals.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'PassionFruit', home: Page());
  }
}

// ! stful & stless
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

  // ! CHANGE
  static const List<Widget> _widgetOptions = <Widget>[
    Text('Index 0: Home'),
    Text('Index 1: Business'),
    Text('Index 2: School'),
  ];

  // Update page function
  void _onNavBarTapped(int i) {
    setState(() {
      _pageIndex = i;
    });
    print(_pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'PassionFruit',
        home: Scaffold(
            // * PAGE
            body: Center(
              child: _widgetOptions.elementAt(_pageIndex),
            ),

            // * NAV BAR
            bottomNavigationBar: NavBar(_pageIndex, _onNavBarTapped)));
  }
}

class NavBar extends StatefulWidget {
  int index;
  Function(int) callback;
  NavBar(this.index, this.callback);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color(MAIN_COLOR),
      unselectedItemColor: Color(SECOND_ACCENT_COLOR),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.collections_bookmark),
          label: 'Bookshelf',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
      ],
      currentIndex: widget.index,
      selectedItemColor: Color(MAIN_ACCENT_COLOR),
      onTap: widget.callback,
    );
  }
}
