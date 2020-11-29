import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as chart;
// import '../helpers/globals.dart';
import '../widgets/map.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Set initial zoom and translation (!translation not working)
  final _zoomer = TransformationController(Matrix4.diagonal3Values(1, 1, 1));
  List<chart.Series> chartData = [];
  // Matrix4.translationValues(5, 5, 0)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildSearchBar(),
        body: InteractiveViewer(
            maxScale: 1.0, transformationController: _zoomer, child: Graph()));
  }

  // * SEARCH BAR
  Widget buildSearchBar() {
    return AppBar(
      title: TextField(
          decoration:
              InputDecoration(border: InputBorder.none, hintText: 'Search...')),
      leadingWidth: 0,
      toolbarHeight: 45,
      toolbarOpacity: 0.1,
      backgroundColor: Color(0xFFF2F2F2),
      shadowColor: Color(0xFF888888),
      actions: [
        Icon(
          Icons.search,
          color: Colors.grey,
        )
      ],
    );
  }
}
