import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/helpers/storage.dart';
import 'package:PassionFruit/helpers/suggestion.dart';
import 'package:PassionFruit/widgets/feed/itemView.dart';
import 'package:PassionFruit/widgets/feed/itemFeed.dart';
import 'package:PassionFruit/pages/settings.dart';

class FeedPage extends StatefulWidget {
  final loadBuffer = 3; // How many items to preload
  final _state = _FeedPageState();

  pause(context, int i) {
    _state.pageSwitch(context, i);
  }

  @override
  _FeedPageState createState() => _FeedPageState();
}

const NO_ITEM = '';

class _FeedPageState extends State<FeedPage> {
  final _swiper = PageController(viewportFraction: 0.9);
  List<Future<String>> sites = []; // Store suggestion history
  // For timing
  String currentSite = NO_ITEM;
  DateTime startTime = DateTime.now();
  int duration = 0;

  @override
  void dispose() {
    _swiper.dispose();
    super.dispose();
  }

  // * Uses page indexes to
  pageSwitch(context, int i) async {
    String newSite = NO_ITEM; // ! MISTAKE ON FIRST VIEW
    // ignore: invalid_use_of_protected_member
    if (_swiper.positions.isNotEmpty)
      newSite = await sites[_swiper.page.round()];
    timePage(context, newSite);
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

  // * Rendering
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Feed'), actions: [
        IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => pushNewScreen(context, screen: SettingsPage())),
      ]),
      body: feedBuilder(),
    );
  }

  Widget feedBuilder() {
    final sg = Suggestor(context);
    // ? https://pub.dev/packages/preload_page_view
    return PageView.builder(
      controller: _swiper,
      onPageChanged: (i) => pageSwitch(context, i),
      itemBuilder: (BuildContext context, int i) {
        if (sites.length - widget.loadBuffer <= i) sites.add(sg.suggest());
        // Get suggestion
        return FutureBuilder(
          future: sites[i],
          builder: (context, snap) {
            if (snap.hasData)
              return GestureDetector(
                child: FeedItem(snap.data),
                onTap: () => pushNewScreen(context,
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.fade,
                    screen: ViewItem(snap.data)),
              );
            else
              return LoadingWidget;
          },
        );
      },
    );
  }
}
