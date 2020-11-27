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
  void initState() {
    // loadVitals().then((map) => setState(() => chartData = _formatPoints(map)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildSearchBar(),
        body: InteractiveViewer(
            maxScale: 1.0, transformationController: _zoomer, child: Map()));
    // child: chart.ScatterPlotChart(chartData, animate: true)));
    // floatingActionButton: Slider(
    //     value: 4,
    //     divisions: 4,
    //     min: 0,
    //     max: 4,
    //     onChanged: (double newVal) {}));
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

  // * SCATTER MAP
  // // Returns the list of chart series
  // List<chart.Series<MapPoint, int>> _formatPoints(List<List<dynamic>> map) {
  //   // ! SPLIT BY CATEGORY
  //   final List<MapPoint> chartData = List<MapPoint>.generate(map.length, (i) {
  //     final data = map[i];
  //     return MapPoint(
  //         name: data[MapCol.name.index],
  //         x: data[MapCol.x.index],
  //         y: data[MapCol.y.index]);
  //   });

  //   final you = MapPoint(name: 'You', x: 5, y: 5);

  //   return <chart.Series<MapPoint, int>>[
  //     _getSeries(data: chartData, name: 'People'),
  //     // ! STORE YOU VALUE
  //     _getSeries(data: [you], name: 'You'),
  //   ];
  // }

  // chart.Series<MapPoint, int> _getSeries({List<MapPoint> data, String name}) {
  //   return chart.Series<MapPoint, int>(
  //       id: name,
  //       data: data,
  //       domainFn: (MapPoint p, _) => p.x,
  //       measureFn: (MapPoint p, _) => p.y);
  // }
}

class MapPoint {
  String name = '';
  final int x;
  final double y;
  MapPoint({this.name, this.x, this.y});
}
