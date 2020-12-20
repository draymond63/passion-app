import 'package:PassionFruit/helpers/csv.dart';
import 'package:PassionFruit/helpers/globals.dart';
import 'package:flutter/material.dart';
// import 'package:charts_flutter/flutter.dart' as chart;
// import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/widgets/map.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchBar(),
      body: FutureBuilder(
        future: loadMap(),
        builder: (context, AsyncSnapshot snap) {
          if (snap.hasData) {
            print(snap.data);
            final map = CSV(csv: snap.data);
            return Container(
                width: MediaQuery.of(context).size.width, child: Graph(map));
          }
          if (snap.hasError) return Text('${snap.error}');
          return LoadingWidget;
        },
      ),
    );
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
