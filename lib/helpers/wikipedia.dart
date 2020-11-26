// import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import './globals.dart';
import 'dart:convert';

const WIKI_API = 'https://en.wikipedia.org/w/api.php?';

//https://en.wikipedia.org/w/api.php?action=query&prop=extracts&explaintext=1&titles=LeBron_James

class Wiki with ChangeNotifier {
  Map<String, Future> itemMemoizer = {};

  Future fetchItem(String title) {
    // If we have not retrieved the item before, save it
    if (!itemMemoizer.containsKey(title)) {
      itemMemoizer[title] = _fetchItemData(title);
    } else
      print("USING SAVED ITEM: " + title);
    return itemMemoizer[title];
  }

  Future<Map<String, dynamic>> _fetchItemData(String title) async {
    print("FETCHING ITEM: " + title);
    final images = _queryWiki(title, 'images');
    final content = _queryWiki(title, 'content');
    final data = await Future.wait([images, content]);
    final imageUrl = _parseImageUrl(data[0], title);
    dynamic image;

    try {
      image = CachedNetworkImageProvider(imageUrl);
    } catch (e) {
      image = null;
    }
    return {'name': title, 'image': image, 'content': _parseContent(data[1])};
  }

  Future<Map> _queryWiki(String name, String type) async {
    final vitals = await loadVitals();
    final row = vitals.firstWhere(
      (row) => row[MapCol.name.index] == name,
      orElse: () => throw Exception('$name not found in dataset'),
    );
    final site = row[MapCol.site.index];

    String uri = 'action=query&format=json&origin=*&titles=' + site;
    switch (type) {
      case 'images':
        uri += '&generator=images&gimlimit=max&prop=imageinfo&iiprop=url';
        break;
      case 'content':
        uri += '&prop=extracts&explaintext=1';
        break;
      default:
        throw Exception('Fetch wiki type of "$type" not found');
    }
    // Send request
    final http.Response resp = await http.get(WIKI_API + uri);
    // print(resp.body);
    // print(jsonDecode(resp.body)['data']);
    if (resp.statusCode == 200)
      return jsonDecode(resp.body);
    else
      throw Exception('Failed to fetch');
  }

  String _parseImageUrl(Map json, String title) {
    final pages = json['query']['pages'];

    for (final obj in pages.values) {
      final String cUrl = obj['imageinfo'][0]['url'];
      // cUrl.contains(title.split(' ')[0]) &&
      if (!cUrl.contains('svg')) return cUrl;
    }
    return pages[pages.keys.toList()[0]]['imageinfo'][0]['url'];
    // return 'https://upload.wikimedia.org/wikipedia/commons/7/7a/Basketball.png';
  }

  String _parseContent(Map json) {
    final String pageId = json['query']['pages'].keys.toList()[0];
    return json['query']['pages'][pageId]['extract'];
  }
}
