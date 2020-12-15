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
    // Add item to the list
    final db = Provider.of<Storage>(context, listen: false);
    final status = db.addItem(site);
    if (!status) db.removeItem(site);
    // Show feedback
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Color(MAIN_ACCENT_COLOR),
      content: Text('Added $name to your bookmarks!', // ! UPDATE TEXT ON DELETE
          style: TextStyle(color: Color(MAIN_COLOR))),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final wiki = Provider.of<Wiki>(context);
    final vitals = Provider.of<List<List>>(context);

    return FutureBuilder<Map>(
      future: wiki.fetchItem(widget.site),
      builder: (context, snap) {
        if (snap.hasData)
          return ListView(children: buildContent(snap.data, vitals));
        if (snap.hasError) return Center(child: Text('${snap.error}'));
        return LoadingWidget;
      },
    );
  }

  List<Widget> buildContent(Map data, List<List> vitals) {
    // Get vitals row info for the site
    final info = vitals.firstWhere(
      (row) => row[VitCol.site.index] == widget.site,
      orElse: () => List.filled(VitCol.values.length, ''),
    );

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
      Center(child: Text(info[VitCol.name.index], style: ItemHeader)),
      // * BUTTONS
      Center(
        child: IconButton(
          icon: Icon(Icons.thumb_up_rounded),
          color: Color(0xFFAAAAAA),
          onPressed: () =>
              addLikedItem(context, info[VitCol.name.index], widget.site),
        ),
      ),
      // * TEXT
      Container(padding: EdgeInsets.all(8), child: Text(data['content'])),
    ];
  }
}
