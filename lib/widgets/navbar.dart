import 'package:flutter/material.dart';
import '../globals.dart';

class NavBar extends StatefulWidget {
  final index;
  final Function changePage;
  NavBar(this.index, this.changePage);
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  static const double _iconSize = 36;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Color(MAIN_COLOR),
      unselectedItemColor: Color(SECOND_ACCENT_COLOR),
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.settings, size: _iconSize),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.collections_bookmark, size: _iconSize),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search, size: _iconSize),
          label: '',
        ),
      ],
      currentIndex: widget.index,
      selectedItemColor: Color(MAIN_ACCENT_COLOR),
      unselectedFontSize: 0, // ! REMOVES LABELS
      selectedFontSize: 0,
      onTap: widget.changePage,
    );
  }
}
