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
                      return buildItems(data.items);
                    }),
                // https://pub.dev/documentation/graphview/latest/
                Text('Your Tree', style: ItemHeader),
                Text('Get all the paths of every item...')
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
