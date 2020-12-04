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
  List<String> sites = [];

  @override
  void initState() {
    super.initState();
    // ! CHOOSE RANDOM SUGGESTION FOR NOW
    Future.delayed(Duration(seconds: 0), () async {
      final csv = Provider.of<List<List>>(context, listen: false);
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
        if (sites.length <= i) return LoadingWidget;
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
