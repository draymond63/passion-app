import 'package:PassionFruit/widgets/feed/itemFlag.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
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
    String message = 'Added $name to your bookmarks!';
    // Add item to the list
    final db = Provider.of<Storage>(context, listen: false);
    final status = db.addItem(site, context);
    if (!status) {
      db.removeItem(site, context);
      message = 'Removed $name from your bookmarks';
    }
    // Show feedback
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: Color(MAIN_ACCENT_COLOR),
      content: Text(message, style: TextStyle(color: Color(MAIN_COLOR))),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final wiki = Provider.of<Wiki>(context);
    final vitals = Provider.of<Map>(context);

    return FutureBuilder<WikiDoc>(
      future: wiki.fetchItem(widget.site),
      builder: (context, snap) {
        if (snap.hasData)
          return ListView(children: buildContent(context, snap.data, vitals));
        if (snap.hasError) return Center(child: Text('${snap.error}'));
        return LoadingWidget;
      },
    );
  }

  List<Widget> buildContent(BuildContext context, WikiDoc doc, Map vitals) {
    final showImage = Provider.of<Storage>(context).settings.data['show_image'];
    // Get vitals row info for the site
    final info = vitals[widget.site];
    // Check to see if any images were available
    Image image;
    if (showImage)
      image = doc.imageUrl == ''
          ? Image.asset('assets/fruit.png', fit: BoxFit.cover)
          : Image(
              image: CachedNetworkImageProvider(doc.imageUrl),
              fit: BoxFit.cover,
            );

    return [
      // * IMAGE
      if (showImage) widget.buildImage(image),
      Text(
        info['name'] ?? widget.site,
        textAlign: TextAlign.center,
        style: ItemHeader,
      ),
      // * BUTTONS
      buildButtons(context, info),
      // * TEXT
      Container(padding: EdgeInsets.all(8), child: Text(doc.content)),
    ];
  }

  Widget buildButtons(BuildContext context, Map info) {
    Color color = Color(SECOND_ACCENT_COLOR);
    final store = Provider.of<Storage>(context);
    if (store.items.contains(widget.site)) color = Color(MAIN_COLOR);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Only give the option to flag if the user is willing to send data
        if (store.settings.data['send_data'])
          IconButton(
              icon: Icon(Icons.flag),
              color: Color(SECOND_ACCENT_COLOR),
              onPressed: () => pushNewScreen(context,
                  screen: FlagItemPage(widget.site),
                  pageTransitionAnimation: PageTransitionAnimation.fade)),
        // Spacing for two icons
        if (store.settings.data['send_data']) SizedBox(width: 50),
        // Like button
        IconButton(
            icon: Icon(Icons.thumb_up_rounded),
            color: color,
            onPressed: () => addLikedItem(context, info['name'], widget.site)),
      ],
    );
  }
}
