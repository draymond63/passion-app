import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/helpers/storage.dart';
import 'package:PassionFruit/widgets/bookshelf/itemPreview.dart';
import 'package:PassionFruit/widgets/feed/itemFeed.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IntroPage extends StatefulWidget {
  final void Function() pop;
  IntroPage(this.pop);
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  int _pageIndex = 0;
  List<Widget> _pages;
  Widget currentPage;

  @override
  void initState() {
    super.initState();
    _pages = [page1, page2, page3, page4, page5, page6, page7];
    currentPage = _pages[_pageIndex];
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: currentPage,
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("${_pageIndex + 1}/${_pages.length}"),
              if (_pageIndex != 0)
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: prevPage,
                )
            ],
          ),
        ),
        onTap: nextPage,
      );

  nextPage() {
    _pageIndex++;
    if (_pageIndex >= _pages.length) {
      Provider.of<Storage>(context, listen: false).initUser = false;
      widget.pop(); // Should pop page
    } else
      setState(() => currentPage = _pages[_pageIndex]);
  }

  prevPage() {
    _pageIndex--;
    setState(() => currentPage = _pages[_pageIndex]);
  }

  final page1 =
      Center(child: Text('Welcome to PassionFruit!', style: ItemHeader));

  final page2 = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "We hope you're excited to begin our journey!\n",
        style: ItemHeader,
        textAlign: TextAlign.center,
      ),
      Text(
        "In PassionFruit there are two ways to explore:\n\nThe Feed\nThe Search",
        style: ItemSubtitle,
        textAlign: TextAlign.center,
      ),
    ],
  );

  final page3 = Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text(
        "The Feed\n",
        style: ItemHeader,
        textAlign: TextAlign.center,
      ),
      Text(
        "This is where we suggest topics to you! If you enjoy what you see, give it a like!\n\nAs you scroll through you will be matched with more relevant content :)",
        style: ItemSubtitle,
        textAlign: TextAlign.center,
      ),
      Container(
        child: IgnorePointer(child: FeedItem('Chaos_theory')),
        height: 380,
      ),
    ],
  );

  final page4 = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "The Search\n",
        style: ItemHeader,
        textAlign: TextAlign.center,
      ),
      Text(
        "This is where your learning takes a less linear approach! As you like topics, you (a star 🌟) will be placed in the map of all content.\n\nFeel free to scroll through the 40 000+ possibilities, search up curiosities, or click the random button for something new!",
        style: ItemSubtitle,
        textAlign: TextAlign.center,
      ),
    ],
  );

  final page5 = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Track Progress Personally\n",
        style: ItemHeader,
        textAlign: TextAlign.center,
      ),
      Text(
        "When you like items, they will appear in your bookmarks.\n\nUse this to keep track of your interests and see what genres you are interested in!\n\n",
        style: ItemSubtitle,
        textAlign: TextAlign.center,
      ),
      IgnorePointer(child: PreviewItem('Chaos_theory'))
    ],
  );

  final page6 = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Your Data\n",
        style: ItemHeader,
        textAlign: TextAlign.center,
      ),
      Text(
        "To improve the app, we keep track of your interests as well.\n\nTo store all your data locally, turn off sending information in the \"Data Settings\" section of settings (located on the feed page). Please explore other settings there too!",
        style: ItemSubtitle,
        textAlign: TextAlign.center,
      ),
    ],
  );

  final page7 = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Enjoy!\n",
        style: ItemHeader,
        textAlign: TextAlign.center,
      ),
      Text(
        "If you have any questions, concerns, or compliments let us know on the app store!",
        style: ItemSubtitle,
        textAlign: TextAlign.center,
      ),
    ],
  );
}
