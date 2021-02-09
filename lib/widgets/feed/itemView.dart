import 'package:flutter/material.dart';
import 'package:PassionFruit/widgets/feed/itemBase.dart';

class ViewItem extends StatelessWidget {
  final String site;
  const ViewItem(this.site);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_back),
        onPressed: Navigator.of(context).pop,
      ),
      body: Container(
        child: BaseItem(
          site: site,
          buildImage: buildImage,
          buildText: (t) => t, // Leave text unaltered
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
