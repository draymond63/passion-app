import 'package:flutter/material.dart';
import '../helpers/globals.dart';
// For the like button
import '../helpers/firebase.dart';

class FeedItem extends StatefulWidget {
  final String name;
  final image;
  final String content;
  final double width; // Fraction of viewport
  final double height; // image height
  const FeedItem(
      {this.name = '',
      this.image,
      this.content = '',
      this.width = 0.8,
      this.height = 256});
  @override
  _FeedItemState createState() => _FeedItemState();

  factory FeedItem.fromMap({Map map, width = 0.8, height = 256.0}) {
    return FeedItem(
        name: map['name'],
        content: map['content'],
        image: map['image'],
        width: width,
        height: height);
  }
}

class _FeedItemState extends State<FeedItem> {
  final db = DBService();

  void addLikedItem(BuildContext context) {
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Color(MAIN_ACCENT_COLOR),
      content: Text('Added ${widget.name} to your liked topics!',
          style: TextStyle(color: Color(MAIN_COLOR))),
    ));
    db.writeItem(context, widget.name);
  }

  @override
  Widget build(BuildContext context) {
    // For keepAlive
    final width = MediaQuery.of(context).size.width;

    return Container(
      child: Column(children: [
        // * IMAGE
        buildImage(),
        Text(widget.name, style: ItemHeader),
        // * BUTTONS
        Center(
            child: IconButton(
                icon: Icon(Icons.thumb_up_rounded),
                color: Color(0xFFAAAAAA),
                onPressed: () => addLikedItem(context))),
        // * TEXT
        buildText(),
      ]),
      // * FORMATTING
      width: width * widget.width,
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

  Widget buildImage() {
    try {
      return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.height),
              child: SizedBox.expand(
                  child: Image(image: widget.image, fit: BoxFit.cover))));
    } catch (e) {
      return Container();
    }
  }

  Widget buildText() {
    return Flexible(
      child: Container(
          padding: EdgeInsets.all(8),
          child: Text(
            widget.content,
            overflow: TextOverflow.fade,
            softWrap: true,
          )),
    );
  }
}
