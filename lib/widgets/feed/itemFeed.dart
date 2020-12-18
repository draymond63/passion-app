import 'package:PassionFruit/widgets/feed/itemBase.dart';
import 'package:flutter/material.dart';

class FeedItem extends StatelessWidget {
  final String site;
  const FeedItem(this.site);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BaseItem(
        site: site,
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

  Widget buildImage(Image image) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 256),
        child: SizedBox.expand(
          child: image,
        ),
      ),
    );
  }
}
