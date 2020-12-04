import 'package:PassionFruit/widgets/tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../helpers/globals.dart';
import '../helpers/firebase.dart';
import '../widgets/itemPreview.dart';

class BookShelfPage extends StatelessWidget {
  final db = DBService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            minimum: EdgeInsets.all(8),
            child: ListView(
              children: [
                // Text('Most common category:', style: ItemSubtitle),
                Text('Bookmarks', style: ItemHeader),
                StreamBuilder(
                    stream: db.getUserData(context),
                    builder: (context, AsyncSnapshot snap) {
                      User data = User();
                      if (snap.data is User) data = snap.data;
                      // Reverse to show most recent first
                      return buildItems(data.items.reversed.toList());
                    }),
                // https://pub.dev/documentation/graphview/latest/
                Text('Your Tree', style: ItemHeader),
                TreeViewer(),
              ],
            )));
  }

  Widget buildItems(List<String> sites) {
    if (sites.length == 0)
      return Center(
          child: Text("There's nothing here ¯\\_(ツ)_/¯", style: ItemSubtitle));
    // If we have items, display them
    return ConstrainedBox(
      // ! PROBABLY SHOULDN'T HARDCODE
      constraints: BoxConstraints(maxHeight: 115),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List<PreviewItem>.generate(
            sites.length, (i) => PreviewItem(sites[i])),
      ),
    );
  }
}
