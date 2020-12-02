import 'package:PassionFruit/widgets/itemBase.dart';
import 'package:flutter/material.dart';

class FeedItem extends StatefulWidget {
  final String site;
  const FeedItem(this.site);
  @override
  _FeedItemState createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: BaseItem(
        site: widget.site,
        buildImage: buildImage,
      ),
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
}
