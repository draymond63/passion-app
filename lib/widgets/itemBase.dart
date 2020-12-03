import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../helpers/wikipedia.dart';
import '../helpers/globals.dart';
// For the like button
import '../helpers/firebase.dart';

class BaseItem extends StatefulWidget {
  final String site;
  final Widget Function(CachedNetworkImageProvider) buildImage;
  BaseItem({this.site, this.buildImage});
  @override
  _BaseItemState createState() => _BaseItemState();
}

class _BaseItemState extends State<BaseItem> {
  final db = DBService();

  void addLikedItem(BuildContext context, String name, String site) {
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Color(MAIN_ACCENT_COLOR),
      content: Text('Added $name to your bookmarks!',
          style: TextStyle(color: Color(MAIN_COLOR))),
    ));
    db.writeItem(context, site);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Wiki>(
      builder: (_, wiki, c) => FutureBuilder(
          future: wiki.fetchItem(widget.site),
          builder: (context, snap) {
            if (snap.hasData)
              return ListView(children: buildContent(snap.data));
            if (snap.hasError) return Center(child: Text('${snap.error}'));
            return Text('Loading', style: ItemSubtitle);
          }),
    );
  }

  List<Widget> buildContent(Map data) {
    return [
      // * IMAGE
      widget.buildImage(data['image']),
      Center(child: Text(data['name'], style: ItemHeader)),
      // * BUTTONS
      Center(
          child: IconButton(
              icon: Icon(Icons.thumb_up_rounded),
              color: Color(0xFFAAAAAA),
              onPressed: () =>
                  addLikedItem(context, data['name'], data['site']))),
      // * TEXT
      Container(padding: EdgeInsets.all(8), child: Text(data['content'])),
    ];
  }
}