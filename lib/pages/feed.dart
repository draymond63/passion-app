import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

import '../helpers/wikipedia.dart';
import '../helpers/globals.dart';
import '../widgets/itemFeed.dart';
import '../widgets/itemView.dart';
import './settings.dart';

class FeedPage extends StatefulWidget {
  final loadBuffer = 3; // How many items to preload
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final _swiper = PageController(viewportFraction: 0.9);
  List<String> names = [];
  List<Widget> items = [];
  Future<bool> loaded;
  bool showSettings = false;

  @override
  void initState() {
    super.initState();
    // ! CHOOSE RANDOM SUGGESTION FOR NOW
    loaded = loadVitals().then((List<List> csv) {
      csv.shuffle();
      final temp = List<String>.generate(
          csv.length, (i) => csv[i][VitCol.name.index].toString());
      setState(() => names = temp);
      return true;
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
    final wiki = Provider.of<Wiki>(context);

    return PageView.builder(
      controller: _swiper,
      itemBuilder: (BuildContext context, int i) {
        print('$i : ${items.length}');
        if (items.length < i + widget.loadBuffer) _getNewItems(wiki);
        if (items.length <= i)
          return Center(child: Text('Loading', style: ItemSubtitle));
        return items[i];
      },
    );
  }

  _getNewItems(Wiki wiki) async {
    // Wait for vitals to load in names
    await loaded;
    // Pop name frome state (we don't need to rerender)
    final name = names.removeAt(0);
    final data = await wiki.fetchItem(name);
    if (mounted) items.add(buildFeedItem(data));
  }

  buildFeedItem(Map data) {
    return GestureDetector(
        onTap: () => pushNewScreen(context,
            screen: ViewItem.fromMap(map: data),
            withNavBar: false,
            pageTransitionAnimation: PageTransitionAnimation.fade),
        child: FeedItem.fromMap(map: data));
  }
}
