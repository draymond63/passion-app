import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'package:PassionFruit/helpers/firebase.dart';
import 'package:PassionFruit/widgets/feed/itemView.dart';
import '../helpers/globals.dart';
import '../widgets/feed/itemFeed.dart';
import './settings.dart';

class FeedPage extends StatefulWidget {
  final loadBuffer = 3; // How many items to preload
  final _state = _FeedPageState();

  pause(context, int i) {
    _state.pageSwitch(context, i);
  }

  @override
  _FeedPageState createState() => _state;
}

class _FeedPageState extends State<FeedPage> {
  final _swiper = PageController(viewportFraction: 0.9);
  List<String> sites = [];
  // For timing
  String currentSite = '';
  DateTime startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0), () {
      _swiper.addListener(() => timePage(context, sites[_swiper.page.round()]));
    });
  }

  // * Uses page indexes to
  pageSwitch(context, int i) {
    if (i != 0) // ! ASSUMES FEED PAGE IS THE FIRST IN THE NAVBAR
      timePage(context, '');
    else {
      String newSite = ''; // ! BREAKS ON FIRST VIEW
      if (_swiper.positions.isNotEmpty) newSite = sites[_swiper.page.round()];
      timePage(context, newSite);
    }
  }

  timePage(context, newSite) {
    final db = DBService();
    // If the page has switched, change the currentSite
    if (currentSite != newSite) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds ~/ 100;
      print('$currentSite: ${duration / 10}');
      // Send to the database
      if (currentSite != '') db.updateTime(context, currentSite, duration);
      // Setup for new page tracking
      startTime = endTime;
      currentSite = newSite;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vitals = Provider.of<List<List>>(context);
    sites = List<String>.generate(
        vitals.length, (i) => vitals[i][VitCol.site.index].toString());
    sites.shuffle();

    return Scaffold(
        appBar: AppBar(
          title: Text('Your Feed'),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () => pushNewScreen(context, screen: SettingsPage()),
            ),
          ],
        ),
        body: feedBuilder(sites));
  }

  Widget feedBuilder(List items) {
    return PageView.builder(
      controller: _swiper,
      itemBuilder: (BuildContext context, int i) {
        if (items.length <= i) return LoadingWidget;
        return GestureDetector(
            onTap: () => pushNewScreen(context,
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.fade,
                screen: ViewItem(items[i])),
            child: FeedItem(items[i]));
      },
    );
  }
}
