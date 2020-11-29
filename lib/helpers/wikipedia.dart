// import 'package:async/async.dart';
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './globals.dart';
import './csv.dart';

const WIKI_API = 'https://en.wikipedia.org/w/api.php?';

//https://en.wikipedia.org/w/api.php?action=query&prop=extracts&explaintext=1&titles=LeBron_James

class Wiki {
  Map<String, Future> itemMemoizer = {};
  CSV vitals = CSV.vitals();

  Future fetchItem(String title) {
    // If we have not retrieved the item before, save it
    if (!itemMemoizer.containsKey(title)) {
      itemMemoizer[title] = _fetchItemData(title);
    }
    return itemMemoizer[title];
  }

  // * Get all data required to display an item
  Future<Map<String, dynamic>> _fetchItemData(String title) async {
    // Pull in wiki content
    final images = _queryWiki(title, 'images');
    final content = _queryWiki(title, 'content');
    final data = await Future.wait([images, content]);
    // Image selection
    final imageUrl = _parseImageUrl(data[0], title);
    dynamic image = Image.asset('assets/fruit.png');
    // Image checking
    final extensions = ['png', 'jpg', 'gif'];
    final ext = imageUrl.split('.').last;
    if (extensions.contains(ext)) image = CachedNetworkImageProvider(imageUrl);
    // Return data
    return {'name': title, 'image': image, 'content': _parseContent(data[1])};
  }

  // * Search wikipedia for a given item
  Future<Map> _queryWiki(String name, String type) async {
    // Wait for vitals csv to load
    while (!vitals.isLoaded) {}

    final row = vitals.dataRowFirst.firstWhere(
      (row) => row[VitCol.name.index] == name,
      orElse: () => throw Exception('$name not found in dataset'),
    );
    final site = row[VitCol.site.index];

    // Create a url depending on the request
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
    if (resp.statusCode == 200)
      return jsonDecode(resp.body);
    else
      throw Exception('Failed to fetch');
  }

  // * Functions to extract the best image and content
  String _parseImageUrl(Map json, String title) {
    final pages = json['query']['pages'];

    for (final obj in pages.values) {
      if (obj.runtimeType == 'Map') {
        final String cUrl = obj['imageinfo'][0]['url'];
        // cUrl.contains(title.split(' ')[0]) &&
        if (!cUrl.contains('svg')) return cUrl;
      }
    }
    return pages[pages.keys.toList()[0]]['imageinfo'][0]['url'];
    // return 'https://upload.wikimedia.org/wikipedia/commons/7/7a/Basketball.png';
  }

  String _parseContent(Map json) {
    final String pageId = json['query']['pages'].keys.toList()[0];
    return json['query']['pages'][pageId]['extract'];
  }
}
