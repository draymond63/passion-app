import 'package:flutter/material.dart';
import '../helpers/globals.dart';
// For the like button
import '../helpers/firebase.dart';

class ViewItem extends StatefulWidget {
  final String name;
  final image;
  final String content;
  final double width; // Fraction of viewport
  final double height; // image height
  const ViewItem(
      {this.name = '',
      this.image,
      this.content = '',
      this.width = 0.8,
      this.height = 256});
  @override
  _ViewItemState createState() => _ViewItemState();

  factory ViewItem.fromMap({Map map, width = 0.8, height = 256.0}) {
    return ViewItem(
        name: map['name'],
        content: map['content'],
        image: map['image'],
        width: width,
        height: height);
  }
}

class _ViewItemState extends State<ViewItem> {
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
    return Scaffold(
      body: ListView(shrinkWrap: true, children: [
        // * IMAGE
        buildImage(),
        Center(child: Text(widget.name, style: ItemHeader)),
        // * BUTTONS
        Center(
            child: IconButton(
                icon: Icon(Icons.thumb_up_rounded),
                color: Color(0xFFAAAAAA),
                onPressed: () => addLikedItem(context))),
        // * TEXT
        buildText(),
      ]),
    );
  }

  Widget buildImage() {
    try {
      return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: widget.height),
          child: SizedBox.expand(
              child: Image(image: widget.image, fit: BoxFit.cover)));
    } catch (e) {
      return Container();
    }
  }

  Widget buildText() {
    return Container(
      padding: EdgeInsets.all(8),
      child: Text(
        widget.content,
        softWrap: true,
      ),
    );
  }
}
