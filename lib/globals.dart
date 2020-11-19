import 'package:http/http.dart' as http;
import 'dart:convert';

const MAIN_COLOR = 0xFF2B3A64;
const MAIN_ACCENT_COLOR = 0xFFCFD1D8;
const SECOND_ACCENT_COLOR = 0xFF8B92A2;

const BACKEND = 'http://10.0.2.2:5000/'; // FOR ANDROID

// * FUNCTIONS
fetch(uri, {params = false}) async {
  final http.Response resp = await http.get(BACKEND + uri);
  print(jsonDecode(resp.body)['data']);
  if (resp.statusCode == 200)
    return jsonDecode(resp.body)['data'];
  else
    throw Exception('Failed to fetch');
}
