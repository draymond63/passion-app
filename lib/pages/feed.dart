import 'package:PassionFruit/helpers/storage.dart';
import 'package:PassionFruit/helpers/suggestion.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/widgets/feed/itemView.dart';
import 'package:PassionFruit/widgets/feed/itemFeed.dart';
import 'package:PassionFruit/pages/settings.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatefulWidget {
  final loadBuffer = 3; // How many items to preload
  final _state = _FeedPageState();

  pause(context, int i) {
    _state.pageSwitch(context, i);
  }

  @override
  _FeedPageState createState() => _state;
}

const NO_ITEM = '';

class _FeedPageState extends State<FeedPage> {
  final _swiper = PageController(viewportFraction: 0.9);
  List<String> sites = [];
  Suggestor sg;
  // For timing
  String currentSite = NO_ITEM;
  DateTime startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0), () async {
      _swiper.addListener(() => timePage(context, sites[_swiper.page.round()]));
    });
  }

  // * Uses page indexes to
  pageSwitch(context, int i) {
    if (i != 0) // ! ASSUMES FEED PAGE IS THE FIRST IN THE NAVBAR
      timePage(context, NO_ITEM);
    else {
      String newSite = NO_ITEM; // ! MISTAKE ON FIRST VIEW
      // ignore: invalid_use_of_protected_member
      if (_swiper.positions.isNotEmpty) newSite = sites[_swiper.page.round()];
      timePage(context, newSite);
    }
  }

  timePage(context, newSite) {
    // If the page has switched, change the currentSite
    if (currentSite != newSite) {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds ~/ 100;
      final db = Provider.of<Storage>(context, listen: false);
      // print('$currentSite: ${duration / 10}');
      // Send to the database
      if (currentSite != NO_ITEM) db.updateTime(currentSite, duration, context);
      // Setup for new page tracking
      startTime = endTime;
      currentSite = newSite;
    }
  }

  @override
  Widget build(BuildContext context) {
    sg = Suggestor(context);
    if (sites.length == 0) sites.addAll(sg.suggest(widget.loadBuffer + 1));

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
        body: feedBuilder());
  }

  Widget feedBuilder() {
    return PageView.builder(
      controller: _swiper,
      itemBuilder: (BuildContext context, int i) {
        if (sites.length - widget.loadBuffer <= i) {
          final suggestions = sg.suggest();
          sites.addAll(suggestions);
          return LoadingWidget;
        }
        return GestureDetector(
            onTap: () => pushNewScreen(context,
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.fade,
                screen: ViewItem(sites[i])),
            child: FeedItem(sites[i]));
      },
    );
  }
}
