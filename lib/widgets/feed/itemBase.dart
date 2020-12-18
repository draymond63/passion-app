import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:PassionFruit/helpers/storage.dart';
import 'package:PassionFruit/helpers/wikipedia.dart';
import 'package:PassionFruit/helpers/globals.dart';

class BaseItem extends StatefulWidget {
  final String site;
  final Widget Function(Image) buildImage;
  BaseItem({this.site, this.buildImage});
  @override
  _BaseItemState createState() => _BaseItemState();
}

class _BaseItemState extends State<BaseItem> {
  void addLikedItem(BuildContext context, String name, String site) {
    String message = 'Added $name to your bookmarks!';
    // Add item to the list
    final db = Provider.of<Storage>(context, listen: false);
    final status = db.addItem(site, context);
    if (!status) {
      db.removeItem(site, context);
      message = 'Removed $name from your bookmarks';
    }
    // Show feedback
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Color(MAIN_ACCENT_COLOR),
      content: Text(message, style: TextStyle(color: Color(MAIN_COLOR))),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final wiki = Provider.of<Wiki>(context);
    final vitals = Provider.of<List<List>>(context);

    return FutureBuilder<WikiDoc>(
      future: wiki.fetchItem(widget.site),
      builder: (context, snap) {
        if (snap.hasData)
          return ListView(children: buildContent(snap.data, vitals));
        if (snap.hasError) return Center(child: Text('${snap.error}'));
        return LoadingWidget;
      },
    );
  }

  List<Widget> buildContent(WikiDoc doc, List<List> vitals) {
    // Get vitals row info for the site
    final info = vitals.firstWhere(
      (row) => row[VitCol.site.index] == widget.site,
      orElse: () => List.filled(VitCol.values.length, ''),
    );

    // Check to see if any images were available
    final image = doc.imageUrl == ''
        ? Image.asset('assets/fruit.png', fit: BoxFit.cover)
        : Image(
            image: CachedNetworkImageProvider(doc.imageUrl),
            fit: BoxFit.cover,
          );

    return [
      // * IMAGE
      widget.buildImage(image),
      Center(
          child: Text(
        info[VitCol.name.index] ?? widget.site,
        style: ItemHeader,
      )),
      // * BUTTONS
      buildLikeButton(context, info),
      // * TEXT
      Container(padding: EdgeInsets.all(8), child: Text(doc.content)),
    ];
  }

  Widget buildLikeButton(BuildContext context, List info) {
    final store = Provider.of<Storage>(context);
    Color color = Color(0xFFAAAAAA);
    if (store.items.contains(widget.site)) color = Color(MAIN_COLOR);

    return Center(
      child: IconButton(
        icon: Icon(Icons.thumb_up_rounded),
        color: color,
        onPressed: () =>
            addLikedItem(context, info[VitCol.name.index], widget.site),
      ),
    );
  }
}
