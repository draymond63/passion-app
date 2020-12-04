import 'package:flutter/material.dart';
import 'package:PassionFruit/widgets/feed/itemBase.dart';

class ViewItem extends StatefulWidget {
  final String site;
  const ViewItem(this.site);
  @override
  _ViewItemState createState() => _ViewItemState();
}

class _ViewItemState extends State<ViewItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: BaseItem(
          site: widget.site,
          buildImage: buildImage,
        ),
        // * FORMATTING
        color: Colors.white,
      ),
    );
  }

  Widget buildImage(Image image) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 256),
      child: SizedBox.expand(
        child: image,
      ),
    );
  }
}
