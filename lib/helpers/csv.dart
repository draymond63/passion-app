import 'dart:math' as math;
import './globals.dart';

class CSV {
  // Row first data
  List<List> data = [[]];
  List<List> dataRowFirst = [[]];
  CSV({List<List> csv}) {
    if (csv != null) loadData(csv);
  }

  loadData(List<List> list) {
    dataRowFirst = list;
    // Rearranges the data into column-first by default
    data = List.generate(dataRowFirst[0].length, (x) {
      return List.generate(dataRowFirst.length, (y) {
        return dataRowFirst[y][x];
      });
    });
  }

  String toString() {
    return dataRowFirst.toString();
  }

  // * EXTREMA FUNCTIONS
  double getMax(col) {
    assert([MapCol, VitCol].contains(col.runtimeType));
    final List<double> column =
        data[col.index].map((x) => x as double).toList();
    return column.reduce(math.max);
  }

  double getMin(col) {
    assert([MapCol, VitCol].contains(col.runtimeType));
    final List<double> column =
        data[col.index].map((x) => x as double).toList();
    return column.reduce(math.min);
  }

  double getRange(col) {
    assert([MapCol, VitCol].contains(col.runtimeType));
    return getMax(col) - getMin(col);
  }

  // * GETTERS
  List iRow(int index) {
    assert(index < length, 'row index recieved was greater than CSV length ');
    return dataRowFirst[index];
  }

  List column(col) {
    assert([MapCol, VitCol].contains(col.runtimeType));
    assert(
        col.index < width, 'column index recieved was greater than CSV width');
    return data[col.index];
  }

  List row(index, col) {
    assert([MapCol, VitCol].contains(col.runtimeType));
    return dataRowFirst.firstWhere(
      (row) => row[col.index] == index,
      orElse: () => <String>[], // ! I think this is wrong
    );
  }

  get length => dataRowFirst.length;
  get width => data.length;
  get shape => [length, width];
}
