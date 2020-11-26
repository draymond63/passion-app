import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/wikipedia.dart';
import '../helpers/globals.dart';
import '../widgets/item.dart';
import './settings.dart';

class FeedPage extends StatefulWidget {
  final loadBuffer = 5; // How many items to preload
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage>
    with AutomaticKeepAliveClientMixin {
  List<String> names = [];
  List<Item> items = [];
  bool showSettings = false;
  bool loadingItem = false;

  @override
  void initState() {
    // ! CHOOSE RANDOM SUGGESTION FOR NOW
    loadVitals().then((List<List<dynamic>> csv) {
      // csv.shuffle();
      final temp =
          List<String>.generate(csv.length, (i) => csv[i][MapCol.name.index]);
      setState(() => names = temp);
    });
    super.initState();
    print("CREATING FEED");
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final wiki = context.watch<Wiki>();

    super.build(context); // For keepAlive
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Feed'),
          actions: [
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: () => setState(() => showSettings = !showSettings))
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: showSettings ? SettingsPage() : feedBuilder(wiki),
        ));
  }

  Widget feedBuilder(Wiki wiki) {
    return ListView.builder(itemBuilder: (BuildContext context, i) {
      // Wait for the options to load
      if (i >= names.length) return Item(name: 'Loading');
      // Load images earlier than necessary
      if (i >= items.length - widget.loadBuffer) {
        // Get data
        wiki.fetchItem(names[i]).then((json) {
          if (mounted) setState(() => items.add(Item.fromMap(map: json)));
        });
        return Item(name: 'Loading');
      }
      return items[i];
    });
  }
}
