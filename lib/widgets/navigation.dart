import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import '../helpers/globals.dart';

import '../pages/feed.dart';
// import '../pages/settings.dart';
import '../pages/bookshelf.dart';
import '../pages/search.dart';
// import '../pages/login.dart';

class PageRouter extends StatefulWidget {
  @override
  _PageRouterState createState() => _PageRouterState();
}

class _PageRouterState extends State<PageRouter> {
  static const double _iconSize = 36;
  PersistentTabController _controller =
      PersistentTabController(initialIndex: 1);

  final _pages = <Widget>[
    FeedPage(),
    BookShelfPage(),
    SearchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      navBarStyle: NavBarStyle.style13,
      controller: _controller,
      screens: _pages,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      hideNavigationBarWhenKeyboardShows: true,
      backgroundColor: Color(MAIN_COLOR),
      items: <PersistentBottomNavBarItem>[
        PersistentBottomNavBarItem(
            icon: Icon(Icons.home, size: _iconSize),
            inactiveColor: Colors.blueGrey,
            title: ''),
        PersistentBottomNavBarItem(
            icon: Icon(Icons.bookmark_rounded, size: _iconSize),
            inactiveColor: Colors.blueGrey,
            title: ''),
        PersistentBottomNavBarItem(
            icon: Icon(Icons.search, size: _iconSize),
            inactiveColor: Colors.blueGrey,
            title: ''),
      ],
    );
  }
}
