import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

const MAIN_COLOR = 0xFF2B3A64;
const MAIN_ACCENT_COLOR = 0xFFCFD1D8;
const SECOND_ACCENT_COLOR = 0xFF8B92A2;
const TEXT_COLOR = 0xFF6D7690;

enum MapCol { name, x, y, l0, l1, l2, l3, l4, site }

// * STYLES
const ItemHeader = const TextStyle(
    fontSize: 30, color: Color(MAIN_COLOR), fontWeight: FontWeight.w500);
const ItemSubtitle = const TextStyle(
    fontSize: 20, color: Color(MAIN_COLOR), fontWeight: FontWeight.w500);

// * FUNCTIONS
Future<List<List<dynamic>>> loadVitals() async {
  final csvString = await rootBundle.loadString('assets/map.csv');
  return CsvToListConverter().convert(csvString);
}

Widget futureBuilder(Future<dynamic> future, Widget Function(dynamic) widget) {
  return FutureBuilder<dynamic>(
      future: future,
      builder: (context, AsyncSnapshot<dynamic> obj) {
        if (obj.hasError) print(obj.error);
        if (obj.hasData)
          return widget(obj.data);
        else
          return Text('');
      });
}

// * DATA PERSISTENCE
// Help function to get user file
Future<File> get _localFile async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/user.json');
}

// Write to user file
void writeUserFile(Map<String, dynamic> map) async {
  final file = await _localFile;
  file.writeAsString(jsonEncode(map));
}

// Read from user file
Future<Map<String, dynamic>> readUserFile() async {
  try {
    final file = await _localFile;
    String contents = await file.readAsString();
    return jsonDecode(contents);
  } catch (e) {
    return {};
  }
}

// Make a change to the user file
void editUserFile(void Function(Map<String, dynamic>) edit) {
  readUserFile().then((data) {
    edit(data);
    writeUserFile(data);
  });
}
