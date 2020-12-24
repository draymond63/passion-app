import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'package:PassionFruit/helpers/globals.dart';

import 'package:PassionFruit/pages/feed.dart';
import 'package:PassionFruit/pages/bookshelf.dart';
import 'package:PassionFruit/pages/search.dart';
// import 'package:PassionFruit/pages/login.dart';

class PageRouter extends StatefulWidget {
  @override
  _PageRouterState createState() => _PageRouterState();
}

class _PageRouterState extends State<PageRouter> {
  static const double _iconSize = 36;
  PersistentTabController _controller = PersistentTabController(
    initialIndex: 1,
  );

  @override
  void initState() {
    Future.delayed(
      Duration(seconds: 0),
      () => _controller
          .addListener(() => _pages[0].pause(context, _controller.index)),
    );
    super.initState();
  }

  // Needs to be dynamic so pause function can be called above
  final _pages = <dynamic>[
    FeedPage(),
    BookShelfPage(),
    SearchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      navBarStyle: NavBarStyle.style13,
      controller: _controller,
      screens: List<Widget>.from(_pages),
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
