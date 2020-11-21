import 'package:flutter/material.dart';
import 'package:PassionFruit/globals.dart';
// ! To be qualified for the Syncfusion Community License Program you must have
// ! a gross revenue of less than one (1) million U.S. dollars ($1,000,000.00 USD)
// ! per year and have less than five (5) developers in your organization, and
// ! agree to be bound by Syncfusion’s terms and conditions.
import 'package:syncfusion_flutter_charts/charts.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _userId = 'draymond63';
  List _suggestions = [];

  void getSuggested() async {
    final response = await fetch('suggest/$_userId');
    setState(() => _suggestions = response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildSearchBar(),
        body: buildMap(),
        floatingActionButton: IconButton(
            icon: Icon(Icons.explore_outlined), onPressed: getSuggested));
  }

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

  final isCardView = true;
  Widget buildMap() {
    return SfCartesianChart(
        plotAreaBorderWidth: 0,
        title: ChartTitle(text: isCardView ? '' : 'Knowledge Map'),
        legend: Legend(isVisible: !isCardView),
        primaryXAxis: NumericAxis(isVisible: false),
        primaryYAxis: NumericAxis(isVisible: false),
        tooltipBehavior: TooltipBehavior(enable: true),
        // selectionType: SelectionType.point,
        series: _getDefaultScatterSeries());
  }

  /// Returns the list of chart series
  /// which need to render on the scatter chart.
  List<ScatterSeries<MapPoint, double>> _getDefaultScatterSeries() {
    final List<MapPoint> chartData = <MapPoint>[
      MapPoint(name: 'hi', x: 1, y: 21)
    ];

    return <ScatterSeries<MapPoint, double>>[
      ScatterSeries<MapPoint, double>(
          dataSource: chartData,
          opacity: 0.7,
          xValueMapper: (MapPoint data, _) => data.x,
          yValueMapper: (MapPoint data, _) => data.y,
          dataLabelMapper: (MapPoint data, _) => data.name,
          markerSettings: MarkerSettings(
            height: 15,
            width: 15,
          ),
          dataLabelSettings: DataLabelSettings(isVisible: true),
          selectionBehavior: SelectionBehavior(enable: true),
          name: 'People'),
    ];
  }
}

class MapPoint {
  String name = '';
  final double x;
  final double y;
  MapPoint({this.name, this.x, this.y});
}
