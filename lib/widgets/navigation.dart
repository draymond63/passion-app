import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/helpers/storage.dart';
import 'package:PassionFruit/pages/feed.dart';
import 'package:PassionFruit/pages/bookshelf.dart';
import 'package:PassionFruit/pages/search.dart';
import 'package:PassionFruit/pages/intro.dart';

class PageRouter extends StatefulWidget {
  @override
  _PageRouterState createState() => _PageRouterState();
}

class _PageRouterState extends State<PageRouter> {
  static const double _iconSize = 36;
  int _prevPageIndex;
  PersistentTabController _controller = PersistentTabController(
    initialIndex: 1,
  );

  @override
  void initState() {
    super.initState();
    // Timing
    _controller.addListener(() {
      final store = Provider.of<Storage>(context, listen: false);
      store.timeStampPage(oldPage: _prevPageIndex, newPage: _controller.index);
      _prevPageIndex = _controller.index;
    });

    Future.microtask(() {
      // Initial overview for new users
      if (Provider.of<Storage>(context, listen: false).initUser) {
        OverlayEntry intro; // Page needs to reference itself
        intro = OverlayEntry(builder: (context) => IntroPage(intro.remove));
        Overlay.of(context).insert(intro);
      }
    });
  }

  final _pages = <Widget>[
    FeedPage(),
    BookShelfPage(),
    SearchPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
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
          title: 'Feed',
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.bookmark_rounded, size: _iconSize),
          inactiveColor: Colors.blueGrey,
          title: 'Saved',
        ),
        PersistentBottomNavBarItem(
          icon: Icon(Icons.search, size: _iconSize),
          inactiveColor: Colors.blueGrey,
          title: 'Search',
        ),
      ],
    );
  }
}
