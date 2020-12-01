import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/wikipedia.dart';
import '../helpers/globals.dart';
// For the like button
import '../helpers/firebase.dart';

class ViewItem extends StatefulWidget {
  final String site;
  const ViewItem(this.site);
  @override
  _ViewItemState createState() => _ViewItemState();
}

class _ViewItemState extends State<ViewItem> {
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

    return Scaffold(
      body: Container(
        child: FutureBuilder(
            future: wiki.fetchItem(widget.site),
            builder: (context, snap) {
              if (snap.hasData) {
                final data = snap.data;
                return ListView(children: [
                  // * IMAGE
                  buildImage(data['image']),
                  Text(data['name'], style: ItemHeader),
                  // * BUTTONS
                  Center(
                      child: IconButton(
                          icon: Icon(Icons.thumb_up_rounded),
                          color: Color(0xFFAAAAAA),
                          onPressed: () => addLikedItem(
                              context, data['name'], data['site']))),
                  // * TEXT
                  buildText(data['content']),
                ]);
              }
              return Text('Loading');
            }),
        // * FORMATTING
        color: Colors.white,
      ),
    );
  }

  Widget buildImage(image) {
    try {
      return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 256),
          child:
              SizedBox.expand(child: Image(image: image, fit: BoxFit.cover)));
    } catch (e) {
      return Image.asset('assets/fruit.png');
    }
  }

  Widget buildText(String content) {
    return Container(padding: EdgeInsets.all(8), child: Text(content));
  }
}
