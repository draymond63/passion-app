import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/globals.dart';
import '../helpers/wikipedia.dart';
// For the like button
import '../helpers/firebase.dart';

class FeedItem extends StatefulWidget {
  final String site;
  const FeedItem(this.site);
  @override
  _FeedItemState createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
  final db = DBService();

  void addLikedItem(BuildContext context, String name, String site) {
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Color(MAIN_ACCENT_COLOR),
      content: Text('Added $name to your liked topics!',
          style: TextStyle(color: Color(MAIN_COLOR))),
    ));
    db.writeItem(context, site);
  }

  @override
  Widget build(BuildContext context) {
    final wiki = Provider.of<Wiki>(context);

    return Container(
      child: FutureBuilder(
          future: wiki.fetchItem(widget.site),
          builder: (context, snap) {
            if (snap.hasData) {
              final data = snap.data;
              return Column(children: [
                // * IMAGE
                buildImage(data['image']),
                Text(data['name'], style: ItemHeader),
                // * BUTTONS
                Center(
                    child: IconButton(
                        icon: Icon(Icons.thumb_up_rounded),
                        color: Color(0xFFAAAAAA),
                        onPressed: () =>
                            addLikedItem(context, data['name'], data['site']))),
                // * TEXT
                buildText(data['content']),
              ]);
            }
            return Center(child: Text('Loading'));
          }),
      // * FORMATTING
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Color(0xFFDDDDDD),
                spreadRadius: 1,
                offset: Offset(2, 2),
                blurRadius: 2)
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16))),
    );
  }

  Widget buildImage(image) {
    try {
      return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 256),
              child: SizedBox.expand(
                  child: Image(image: image, fit: BoxFit.cover))));
    } catch (e) {
      return Image.asset('assets/fruit.png');
    }
  }

  Widget buildText(String content) {
    return Flexible(
      child: Container(
          padding: EdgeInsets.all(8),
          child: Text(
            content,
            overflow: TextOverflow.fade,
            softWrap: true,
          )),
    );
  }
}
