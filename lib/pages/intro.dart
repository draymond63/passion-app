import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/helpers/storage.dart';
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
    _pages = [pageOne, pageTwo, pageThree, pageFour, pageFive, pageSix];
    currentPage = _pages[_pageIndex];
  }

  @override
  Widget build(BuildContext context) =>
      GestureDetector(child: currentPage, onTap: nextPage);

  nextPage() {
    _pageIndex++;
    if (_pageIndex >= _pages.length) {
      Provider.of<Storage>(context, listen: false).initUser = false;
      widget.pop(); // Should pop page
    } else
      setState(() => currentPage = _pages[_pageIndex]);
  }

  final pageOne = Scaffold(
    body: Center(
      child: Text('Welcome to PassionFruit!', style: ItemHeader),
    ),
  );

  final pageTwo = Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "We hope you're excited to begin our journey!\n",
            style: ItemHeader,
            textAlign: TextAlign.center,
          ),
          Text(
            "In PassionFruit we have given different ways to learn:\n\nThe Feed\nThe Search",
            style: ItemSubtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  final pageThree = Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "The Feed\n",
            style: ItemHeader,
            textAlign: TextAlign.center,
          ),
          Text(
            "This is where we suggest topics to you! If you enjoy what you see, give it a like! As you scroll through you will be matched with more relevant content :)",
            style: ItemSubtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );

  final pageFour = Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
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
      ),
    ),
  );

  final pageFive = Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Track Progress Personally\n",
            style: ItemHeader,
            textAlign: TextAlign.center,
          ),
          Text(
            "When you like items, they will appear in your bookmarks.\n\nUse this to keep track of your interests and see what genres you are interested in!",
            style: ItemSubtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
  final pageSix = Scaffold(
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Your Data\n",
            style: ItemHeader,
            textAlign: TextAlign.center,
          ),
          Text(
            "To improve the app, we keep track of your interests as well.\n\nTo store all your data locally, turn off sending information in the \"Data Settings\" section of settings (located on the feed page). Explore other settings there too :)",
            style: ItemSubtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
