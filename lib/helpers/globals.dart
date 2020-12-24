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

const VitCol = ['l0', 'l1', 'l2', 'l3', 'l4', 'name'];
enum MapCol { site, x, y, l0 }

// * STYLES
const ItemHeader = const TextStyle(
    fontSize: 30, color: Color(MAIN_COLOR), fontWeight: FontWeight.w500);
const ItemSubtitle = const TextStyle(
    fontSize: 20, color: Color(MAIN_COLOR), fontWeight: FontWeight.w500);

const LoadingWidget = Center(
  child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Color(MAIN_COLOR))),
);

// * FUNCTIONS
Future<Map<String, dynamic>> loadVitals() async {
  final json = await rootBundle.loadString('assets/vitals.json');
  return jsonDecode(json) as Map<String, dynamic>;
}

Future<List<List>> loadMap() async {
  final csvString = await rootBundle.loadString('assets/map.csv');
  return CsvToListConverter().convert(csvString);
}

// * DATA PERSISTENCE
// Help function to get user file
Future<File> get localFile async {
  final directory = await getApplicationDocumentsDirectory();
  return File('${directory.path}/user.json');
}

// Read from user file
Future<Map<String, dynamic>> readUserFile() async {
  try {
    final file = await localFile;
    String contents = await file.readAsString();
    return jsonDecode(contents);
  } catch (e) {
    return {};
  }
}
