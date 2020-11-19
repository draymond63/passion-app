import 'package:flutter/material.dart';
import '../globals.dart';

import 'package:cached_network_image/cached_network_image.dart';

class Item extends StatelessWidget {
  final String site;
  Item(this.site);

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [ItemImage(site), Text(this.site)]);
  }
}

class ItemImage extends StatelessWidget {
  final String site;
  ItemImage(this.site);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: fetch('images/${this.site}'),
      builder: (context, url) {
        if (url.hasData)
          return CachedNetworkImage(
              placeholder: (context, url) => CircularProgressIndicator(),
              imageUrl: url.data[0]);
        else if (url.hasError)
          return Text("Error:" + url.toString());
        else
          return CircularProgressIndicator();
      },
    );
  }
}
