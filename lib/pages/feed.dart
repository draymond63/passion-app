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

  // * TIMING FUNCTIONS
  timePage(index) async {
    // Get the page in question
    final newSite = await sites[index];
    // If the page has switched, change the currentSite
    if (currentSite != newSite) {
      final duration = getDuration();
      final db = Provider.of<Storage>(context, listen: false);
      // print('$currentSite: ${duration / 10}');
      // Send to the database
      if (currentSite != NO_ITEM) db.updateTime(currentSite, duration, context);
      currentSite = newSite;
    }
  }

  // Get the time when this page came into focus
  DateTimeRange get pageStamps =>
      Provider.of<Storage>(context, listen: false).getPageStamps(0);

  // Restart timer and calculate duration
  int getDuration() {
    final endTime = DateTime.now();
    int milli = endTime.difference(startTime).inMilliseconds;
    // If page lost focus, subtract the duration lost
    final arrival = pageStamps.start;
    if (startTime.difference(arrival).isNegative) {
      final timeLost = arrival.difference(pageStamps.end).inMilliseconds;
      milli -= timeLost;
    }
    // Reset item timestamp
    startTime = endTime;
    // Return duration in deciseconds
    return milli ~/ 100;
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
      onPageChanged: timePage,
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
