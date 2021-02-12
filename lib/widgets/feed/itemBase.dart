import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/widgets/feed/itemFlag.dart';
import 'package:PassionFruit/helpers/storage.dart';
import 'package:PassionFruit/helpers/wikipedia.dart';

class BaseItem extends StatefulWidget {
  final String site;
  final Widget Function(Image) buildImage;
  final String Function(String) buildText;
  BaseItem({this.site, this.buildImage, this.buildText});
  @override
  _BaseItemState createState() => _BaseItemState();
}

class _BaseItemState extends State<BaseItem> {
  void addLikedItem(String name, String site) {
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

    return FutureBuilder<WikiDoc>(
      future: wiki.fetchItem(widget.site),
      builder: (context, snap) {
        if (snap.hasData) {
          return buildContent(snap.data);
        }
        // Error prevention
        if (snap.hasError) {
          // Send error over firebase
          final db = Provider.of<Storage>(context, listen: false).db;
          db.sendFlag(context, widget.site, {'Render error': snap.error});
          return Center(
              child: Text(
                  "An error occured loading this topic. We have taken note of it and will fix it soon!"));
        }
        return LoadingWidget;
      },
    );
  }

  Widget buildContent(WikiDoc doc) {
    final showImage = Provider.of<Storage>(context).settings.data['show_image'];
    // Get vitals row info for the site
    final vitals = Provider.of<Map>(context);
    final info = vitals[widget.site] ?? {};
    // Check to see if any images were available
    Image image;
    if (showImage) image = buildImage(doc.imageUrl, info['name']);

    return ListView(children: [
      // * IMAGE
      if (showImage) widget.buildImage(image),
      // * HEADER
      Text(
        info['name'] ?? widget.site,
        textAlign: TextAlign.center,
        style: ItemHeader,
      ),
      // * BUTTONS
      buildButtons(info),
      // * TEXT
      Container(padding: EdgeInsets.all(24), child: buildText(doc.content)),
    ]);
  }

  Image buildImage(String imageUrl, String name) {
    if (imageUrl == '')
      return Image.asset('assets/fruit.png', fit: BoxFit.cover);
    else
      return Image(
        image: CachedNetworkImageProvider(imageUrl,
            // ! TEST IF THIS WORKS
            cacheManager: CacheManager(Config(
              DefaultCacheManager.key,
              maxNrOfCacheObjects: 20,
              stalePeriod: Duration(days: 1),
            ))),
        fit: BoxFit.cover,
        semanticLabel: name,
      );
  }

  Widget buildButtons(Map info) {
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
            onPressed: () => addLikedItem(info['name'], widget.site)),
      ],
    );
  }

  Widget buildText(String content) {
    // return Text(widget.buildText(content));
    final text = widget.buildText(content);
    final sections = parseContent(text);
    return Text.rich(TextSpan(children: sections));
  }

  List<TextSpan> parseContent(String content) {
    final patterns = {
      // 2x equals
      RegExp('\n==[^=]+==\n'): ContentStyle(
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        trimmer: (String s) => '\n' + s.substring(3, s.length - 3) + '\n',
      ),
      // 3x equals
      RegExp('\n===[^=]+===\n'): ContentStyle(
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        trimmer: (String s) => '\n' + s.substring(4, s.length - 4) + '\n',
      ),
      // 4x equals
      RegExp('\n====[^=]+====\n'): ContentStyle(
        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
        trimmer: (String s) => '\n' + s.substring(5, s.length - 5) + '\n',
      ),
      // 5x equals
      RegExp('\n=====[^=]+=====\n'): ContentStyle(
        style: TextStyle(fontStyle: FontStyle.italic),
        trimmer: (String s) => '\n' + s.substring(6, s.length - 6) + '\n',
      ),
      // 5x equals
      RegExp('\n=====[^=]+=====\n'): ContentStyle(
        style: TextStyle(decoration: TextDecoration.underline),
        trimmer: (String s) => '\n' + s.substring(7, s.length - 7) + '\n',
      ),
    };

    var data = [TextSpan(text: content)];

    patterns.forEach((regex, info) {
      // Temporary list for each pattern
      final newData = List<TextSpan>.from(data);
      // Check for the pattern in every textspan
      for (int ii = 0; ii < data.length; ii++) {
        final span = data[ii]; // Iterate through old data
        int startingIndex = 0; // Tells matches where the previous left off
        int insertOffset = 0; // Shifts ii to configure with insertion

        final matches = regex.allMatches(span.text);
        for (final m in matches) {
          // Get relevant text from match
          final matchedText = span.text.substring(m.start, m.end);
          // Split textSpan and insert stylized text
          newData[ii + insertOffset] = TextSpan(
            text: span.text.substring(startingIndex, m.start),
            style: span.style,
          );
          newData.insertAll(ii + 1 + insertOffset, [
            TextSpan(text: info.trimmer(matchedText), style: info.style),
            TextSpan(text: span.text.substring(m.end)),
          ]);
          // Update variables to keep track of insertion
          insertOffset += 2;
          startingIndex = m.end;
        }
      }
      data = newData;
    });
    return data;
  }
}

class ContentStyle {
  final TextStyle style;
  final String Function(String) trimmer;
  ContentStyle({
    @required this.style,
    @required this.trimmer,
  });
}
