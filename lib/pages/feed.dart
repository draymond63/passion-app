import 'package:PassionFruit/widgets/itemView.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../helpers/globals.dart';
import '../widgets/itemFeed.dart';
// import '../widgets/itemView.dart';
import './settings.dart';

class FeedPage extends StatefulWidget {
  final loadBuffer = 3; // How many items to preload
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _swiper = PageController(viewportFraction: 0.9);
  List<String> sites = [];
  Future<List<List>> vitals = loadVitals();

  @override
  void initState() {
    super.initState();
    // ! CHOOSE RANDOM SUGGESTION FOR NOW
    vitals.then((List<List> csv) {
      final temp = List<String>.generate(
          csv.length, (i) => csv[i][VitCol.site.index].toString());
      temp.shuffle();
      setState(() => sites = temp);
    });
  }

  @override
  Widget build(BuildContext context) {
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
        body: feedBuilder(context));
  }

  Widget feedBuilder(context) {
    return PageView.builder(
      controller: _swiper,
      itemBuilder: (BuildContext context, int i) {
        if (sites.length <= i)
          return Center(child: Text('Loading', style: ItemSubtitle));
        return GestureDetector(
            onTap: () => pushNewScreen(context, screen: ViewItem(sites[i])),
            child: FeedItem(sites[i]));
      },
    );
  }
}
