import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'dart:math' as math;
import './globals.dart';

class CSV with ChangeNotifier {
  // Row first data
  List<List<dynamic>> data = [[]];
  List<List<dynamic>> dataRowFirst = [[]];
  bool isLoaded = false;
  CSV({List<List<dynamic>> data}) {
    if (data != null) loadData(data);
  }

  // Takes ~ 3.5 seconds
  factory CSV.vitals() {
    final csv = CSV();
    csv._getAsset('vitals.csv').then((data) => csv.loadData(data));
    return csv;
  }
  factory CSV.map() {
    final csv = CSV();
    csv._getAsset('map.csv').then((data) => csv.loadData(data));
    return csv;
  }

  Future<List<List<dynamic>>> _getAsset(String name) async {
    final csvString = await rootBundle.loadString('assets/' + name);
    return CsvToListConverter().convert(csvString);
  }

  loadData(List<List<dynamic>> list) {
    dataRowFirst = list;
    // Rearranges the data into column-first by default
    data = List.generate(dataRowFirst[0].length, (x) {
      return List.generate(dataRowFirst.length, (y) {
        return dataRowFirst[y][x];
      });
    });
    isLoaded = true;
    notifyListeners();
  }

  String toString() {
    return dataRowFirst.toString();
  }

  // * NOTIFYING LISTENERS

  // * EXTREMA FUNCTIONS
  double getMax(MapCol col) {
    assert(isLoaded, 'CSV must be loaded before function "getMax"');
    final List<double> column =
        data[col.index].map((x) => x as double).toList();
    return column.reduce(math.max);
  }

  double getMin(MapCol col) {
    assert(isLoaded, 'CSV must be loaded before function "getMin"');
    final List<double> column =
        data[col.index].map((x) => x as double).toList();
    return column.reduce(math.min);
  }

  double getRange(MapCol col) {
    assert(isLoaded, 'CSV must be loaded before function "getRange"');
    return getMax(col) - getMin(col);
  }

  // * GETTERS
  List iRow(int index) {
    assert(index < length, 'row index recieved was greater than CSV length ');
    return dataRowFirst[index];
  }

  List column(MapCol col) {
    assert(
        col.index < width, 'column index recieved was greater than CSV width');
    return data[col.index];
  }

  List row(index, col) {
    return dataRowFirst.firstWhere((row) => row[col.index] == index);
  }

  get length => dataRowFirst.length;
  get width => data.length;
  get shape => [length, width];
}
