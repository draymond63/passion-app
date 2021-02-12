import 'package:PassionFruit/helpers/storage.dart';
import 'package:PassionFruit/widgets/bookshelf/tree.dart';
import 'package:PassionFruit/widgets/bookshelf/userStats.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/widgets/bookshelf/itemPreview.dart';

class BookShelfPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('build bookshelf');

    final data = Provider.of<Storage>(context);
    if (data.items.length == 0) return buildEmptyPage();

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
            child: ListView.builder(
              itemCount: sites.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => PreviewItem(sites[i]),
            )),
      ],
    );
  }

  Widget buildEmptyPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Check your feed to start using this page!', style: ItemSubtitle),
        Text(' ¯\\_(ツ)_/¯', style: ItemSubtitle),
      ],
    );
  }
}
