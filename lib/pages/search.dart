import 'package:flutter/material.dart';
import '../helpers/globals.dart';
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
  @override
  void initState() {
    print("CREATING SEARCH");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildSearchBar(),
        body: buildMap(),
        floatingActionButton: Slider(
            value: 4,
            divisions: 4,
            min: 0,
            max: 4,
            onChanged: (double newVal) {}));
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
  final isCardView = true;
  Widget buildMap() {
    return FutureBuilder(
        future: loadVitals(),
        builder: (context, obj) => SfCartesianChart(
            plotAreaBorderWidth: 1,
            title: ChartTitle(text: isCardView ? '' : 'Knowledge Map'),
            legend: Legend(isVisible: !isCardView),
            // ! PROGRAMATICALLY SET RANGE
            primaryXAxis:
                NumericAxis(isVisible: false, minimum: 0, maximum: 10),
            primaryYAxis:
                NumericAxis(isVisible: false, minimum: 0, maximum: 10),
            tooltipBehavior: TooltipBehavior(enable: true),
            zoomPanBehavior: ZoomPanBehavior(enablePinching: true),
            onSelectionChanged: (SelectionArgs info) {
              print(info.pointIndex);
            },
            // selectionType: SelectionType.point,
            series: obj.hasData ? _formatPoints(obj.data) : <ScatterSeries>[]));
  }

  /// Returns the list of chart series
  List<ScatterSeries<MapPoint, double>> _formatPoints(List<List<dynamic>> map) {
    // ! SPLIT BY CATEGORY
    final List<MapPoint> chartData = List<MapPoint>.generate(map.length, (i) {
      final data = map[i];
      return MapPoint(
          name: data[MapCol.name.index],
          x: data[MapCol.x.index],
          y: data[MapCol.y.index]);
    });

    final you = MapPoint(name: 'You', x: 5, y: 5);

    return <ScatterSeries<MapPoint, double>>[
      getSeries(data: chartData, name: 'People'),
      // ! STORE YOU VALUE
      getSeries(data: [you], name: 'You', height: 20, width: 20),
    ];
  }

  ScatterSeries<MapPoint, double> getSeries(
      {List<MapPoint> data,
      String name,
      double width = 15,
      double height = 15}) {
    return ScatterSeries<MapPoint, double>(
        dataSource: data,
        opacity: 0.7,
        xValueMapper: (MapPoint p, _) => p.x,
        yValueMapper: (MapPoint p, _) => p.y,
        dataLabelMapper: (MapPoint p, _) => p.name,
        markerSettings: MarkerSettings(
          height: height,
          width: width,
        ),
        dataLabelSettings: DataLabelSettings(isVisible: true),
        // selectionBehavior: SelectionBehavior(enable: true),
        name: name);
  }
}

class MapPoint {
  String name = '';
  final double x;
  final double y;
  MapPoint({this.name, this.x, this.y});
}
