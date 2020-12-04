import 'package:PassionFruit/widgets/feed/itemView.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

import '../helpers/globals.dart';
import '../widgets/feed/itemFeed.dart';
// import '../widgets/itemView.dart';
import './settings.dart';

class FeedPage extends StatefulWidget {
  final loadBuffer = 3; // How many items to preload
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _swiper = PageController(viewportFraction: 0.9);

  @override
  Widget build(BuildContext context) {
    final vitals = Provider.of<List<List>>(context);
    final sites = List<String>.generate(
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
