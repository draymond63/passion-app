import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../helpers/wikipedia.dart';
import '../helpers/globals.dart';
import '../helpers/firebase.dart';
import '../widgets/itemPreview.dart';

class BookShelfPage extends StatelessWidget {
  final db = DBService();

  @override
  Widget build(BuildContext context) {
    final wiki = Provider.of<Wiki>(context);

    return Scaffold(
        body: SafeArea(
            minimum: EdgeInsets.all(8),
            child: ListView(
              shrinkWrap: true,
              children: [
                Text('Show statics here', style: ItemSubtitle),
                Text('Bookmarks', style: ItemHeader),
                StreamBuilder(
                    stream: db.getUserData(context),
                    builder: (context, AsyncSnapshot snap) {
                      User data = User();
                      if (snap.data is User) data = snap.data;
                      print(data.items);
                      // Show most recent
                      return buildItems(data.items, wiki);
                    }),
                // https://pub.dev/documentation/graphview/latest/
                Text('Your Tree', style: ItemHeader),
                Text('Get all the paths of every item...')
              ],
            )));
  }

  Widget buildItems(List<String> items, Wiki wiki) {
    if (items.length == 0)
      return Center(
          child: Text("There's nothing here ¯\\_(ツ)_/¯", style: ItemSubtitle));
    print(items.toString());
    // If we have items, display them
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 115),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List<PreviewItem>.generate(
            items.length, (i) => PreviewItem(name: items[i])),
      ),
    );
  }
}
