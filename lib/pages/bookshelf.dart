import 'package:flutter/material.dart';
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
      child: StreamBuilder(
          stream: db.getUserData(context),
          initialData: [],
          builder: (context, AsyncSnapshot snap) {
            User data = User();
            if (snap.data is User) data = snap.data;
            // Show most recent
            return buildItems(data.items, wiki);
          }),
    ));
  }

  Widget buildItems(List<String> items, Wiki wiki) {
    if (items.length == 0)
      return Center(
          child: Text("There's nothing here ¯\\_(ツ)_/¯", style: ItemSubtitle));
    // If we have items, display them
    return Container(
      height: 200,
      child: ListView.separated(
        itemCount: items.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) => PreviewItem(name: items[i]),
        separatorBuilder: (_, i) => SizedBox(width: 20),
      ),
    );
  }
}
