import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../helpers/wikipedia.dart';
import '../../helpers/globals.dart';
// For the like button
import '../../helpers/firebase.dart';

class BaseItem extends StatefulWidget {
  final String site;
  final Widget Function(Image) buildImage;
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
    final wiki = Provider.of<Wiki>(context);

    return FutureBuilder<Map>(
      future: wiki.fetchItem(widget.site),
      builder: (context, snap) {
        if (snap.hasData) return ListView(children: buildContent(snap.data));
        if (snap.hasError) return Center(child: Text('${snap.error}'));
        return LoadingWidget;
      },
    );
  }

  List<Widget> buildContent(Map data) {
    // Check to see if any images were available
    final image = data['image'] == ''
        ? Image.asset('assets/fruit.png', fit: BoxFit.cover)
        : Image(
            image: CachedNetworkImageProvider(data['image']),
            fit: BoxFit.cover,
          );

    return [
      // * IMAGE
      widget.buildImage(image),
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
