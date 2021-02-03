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
    _pages = [pageOne(), pageTwo()];
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

  Widget pageOne() => Scaffold(
        body: Center(
          child: Text('Welcome to PassionFruit!\n', style: ItemHeader),
        ),
      );

  Widget pageTwo() => Scaffold(
        backgroundColor: Color(0x55999999),
        body: Center(
          child: Text('Welcome to PassionFruit :)\n', style: ItemHeader),
        ),
      );
}
