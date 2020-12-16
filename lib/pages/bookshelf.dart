import 'package:PassionFruit/helpers/storage.dart';
import 'package:PassionFruit/widgets/bookshelf/tree.dart';
import 'package:PassionFruit/widgets/bookshelf/userStats.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../helpers/globals.dart';
import '../widgets/bookshelf/itemPreview.dart';

class BookShelfPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = Provider.of<Storage>(context);
    final pageItems = [
      SizedBox(),
      UserStatistics(),
      buildItems(data.items.reversed.toList()),
      TreeViewer(),
    ];

    return Scaffold(
        body: SafeArea(
            minimum: EdgeInsets.all(8),
            child: ListView.separated(
              itemCount: pageItems.length,
              itemBuilder: (_, i) => pageItems[i],
              separatorBuilder: (_, i) => SizedBox(height: 30),
            )));
  }

  Widget buildItems(List<String> sites) {
    // If we have items, display them
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bookmarks', style: ItemHeader),
        ConstrainedBox(
          // ! PROBABLY SHOULDN'T HARDCODE
          constraints: BoxConstraints(maxHeight: 115),
          child: sites.length != 0
              ? ListView.builder(
                  itemCount: sites.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) => PreviewItem(sites[i]),
                )
              : Text("There's nothing here ¯\\_(ツ)_/¯", style: ItemSubtitle),
        ),
      ],
    );
  }
}
