import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../helpers/wikipedia.dart';
import '../helpers/globals.dart';
import '../helpers/firebase.dart';
// import '../widgets/item.dart';

class BookShelfPage extends StatelessWidget {
  final db = DBService();

  @override
  Widget build(BuildContext context) {
    final wiki = Provider.of<Wiki>(context);

    return Scaffold(
        body: StreamBuilder(
            stream: db.getUserData(context),
            initialData: [],
            builder: (context, AsyncSnapshot snap) {
              User data = User();
              if (snap.data is User) data = snap.data;
              // Show most recent
              return buildItems(data.items, wiki);
            }));
  }

  Widget buildItems(List<String> items, Wiki wiki) {
    if (items.length == 0)
      return Center(
          child: Text("There's nothing here ¯\\_(ツ)_/¯", style: ItemSubtitle));
    print("LENGTH: " + items.length.toString());
    // If we have items, display them
    return Text('${items.length}');
    // return ListView(
    //     // scrollDirection: Axis.horizontal,
    //     children: List.generate(
    //         items.length,
    //         (i) => futureBuilder(
    //             wiki.fetchItem(items[i]),
    //             (data) => Item.fromMap(
    //                   map: data,
    //                   height: 200.0,
    //                 ))));
  }
}
