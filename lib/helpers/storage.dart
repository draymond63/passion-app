import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/helpers/firebase.dart';

// * Interface for user file
class Storage extends ChangeNotifier {
  final db = DBService();
  // data
  Map<String, bool> _settings = {};
  Map<String, int> _feed = {};
  List<String> _items = [];

  Storage({Map settings, Map feed, List items}) {
    _settings = settings.cast<String, bool>();
    _feed = feed.cast<String, int>();
    _items = items.cast<String>();
  }

  factory Storage.fromMap(Map map) {
    return Storage(
      settings: map['settings'] ??
          {
            'People': true,
            'History': true,
            'Geography': true,
            'Arts': true,
            'Social Sciences': true,
            'Biology': true,
            'Physical Sciences': true,
            'Technology': true,
            'Mathematics': true,
          },
      items: map['items'] ?? [], // 'LeBron_James'
      feed: map['feed'] ?? {},
    );
  }

  factory Storage.fromFile(BuildContext context) {
    final userFile = Provider.of<Map>(context, listen: false);
    return Storage.fromMap(userFile);
  }

  Map<String, dynamic> toMap() {
    return {
      'settings': settings,
      'items': items,
      'feed': feed,
    };
  }

  // * GETTERS
  get settings => _settings;
  get items => _items;
  get feed => _feed;

  // * FUNCTIONS
  _update() {
    notifyListeners();
    writeUserFile(toMap());
  }

  bool addItem(String site) {
    if (!items.contains(site)) {
      _items.add(site);
      _update();
      return true;
    }
    return false;
  }

  bool removeItem(String site) {
    final status = _items.remove(site);
    if (status) _update();
    return status;
  }

  updateTime(String site, int time) {
    if (feed.containsKey(site))
      _feed[site] += time;
    else
      _feed[site] = time;
    _update();
  }
}
