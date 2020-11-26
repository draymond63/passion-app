import 'dart:math' as math;
import './globals.dart';

class CSV {
  // Row first data
  List<List<dynamic>> data = [[]];
  List<List<dynamic>> dataRowFirst;
  CSV({this.data}) {
    dataRowFirst = data;
    // Rearranges the data into column-first by default
    data = List.generate(dataRowFirst[0].length, (x) {
      return List.generate(dataRowFirst.length, (y) {
        return dataRowFirst[y][x];
      });
    });
  }

  get length => data.length;

  double getMax(MapCol col) {
    final List<double> column = data[col.index];
    return column.reduce(math.max);
  }

  double getMin(MapCol col) {
    final List<double> column = data[col.index];
    return column.reduce(math.min);
  }

  double getRange(MapCol col) {
    return getMax(col) - getMin(col);
  }

  // Gets row
  List loc(int index) {
    return dataRowFirst[index];
  }
}
