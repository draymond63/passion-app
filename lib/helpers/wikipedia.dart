import 'package:http/http.dart' as http;
import 'dart:convert';

const WIKI_API = 'https://en.wikipedia.org/w/api.php?';

//https://en.wikipedia.org/w/api.php?action=query&prop=extracts&explaintext=1&titles=LeBron_James

class WikiDoc {
  String site;
  String imageUrl;
  String content;
  WikiDoc({this.site = '', this.imageUrl = '', this.content = ''});

  factory WikiDoc.fromMap(Map<String, String> data) {
    return WikiDoc(
      site: data['site'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      content: data['content'] ?? '',
    );
  }
}

class Wiki {
  Map<String, Future<WikiDoc>> itemMemoizer = {};

  Future<WikiDoc> fetchItem(String site) {
    // If we have not retrieved the item before, save it
    if (!itemMemoizer.containsKey(site)) {
      itemMemoizer[site] = _fetchSite(site);
    }
    return itemMemoizer[site];
  }

  // * Get all data required to display an item
  Future<WikiDoc> _fetchSite(String site) async {
    // Pull in wiki content
    try {
      final images = _queryWiki(site, 'images');
      final content = _queryWiki(site, 'content');
      final data = await Future.wait([images, content]);
      // Image selection
      final imageUrl = _parseImageUrl(data[0]);
      // Return data
      return WikiDoc.fromMap({
        'site': site,
        'image': imageUrl,
        'content': _parseContent(data[1]),
      });
    } catch (e) {
      throw Exception('Failed to retrieve wikipedia info: $e');
    }
  }

  // * Search wikipedia for a given item
  Future<Map> _queryWiki(String site, String type) async {
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
  String _parseImageUrl(Map json) {
    if (!json.containsKey('query')) return '';
    final extensions = ['png', 'jpg', 'gif'];
    final pages = json['query']['pages'];

    for (final obj in pages.values) {
      final String cUrl = obj['imageinfo'][0]['url'];
      final ext = cUrl.split('.').last;
      if (extensions.contains(ext)) return cUrl;
    }
    return '';
  }

  String _parseContent(Map json) {
    if (!json.containsKey('query')) return 'An error has occured';
    final String pageId = json['query']['pages'].keys.toList()[0];
    return json['query']['pages'][pageId]['extract'];
  }
}
