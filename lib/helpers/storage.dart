import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/helpers/firebase.dart';

// * Interface for user file
class Storage extends ChangeNotifier {
  final _db = DBService();
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
            'Philosophy_and_religion': true,
            'Everyday_life': true,
            'Society_and_social_sciences': true,
            'Biological_and_health_sciences': true,
            'Physical_sciences': true,
            'Technology': true,
            'Mathematics': true,
          },
      items: map['items'] ?? [], // 'LeBron_James'
      feed: map['feed'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'settings': settings,
      'items': items,
      'feed': feed,
    };
  }

  // * GETTERS
  Map<String, bool> get settings => _settings;
  List<String> get items => _items;
  Map<String, int> get feed => _feed;

  // * FUNCTIONS
  _update() {
    notifyListeners();
    _writeUserFile(toMap());
  }

  // Write to user file
  void _writeUserFile(Map<String, dynamic> map) async {
    final file = await localFile;
    file.writeAsString(jsonEncode(map));
  }

  // Items
  bool addItem(String site, BuildContext context) {
    if (!items.contains(site)) {
      _items.add(site);
      _db.addItem(context, site);
      _update();
      return true;
    }
    return false;
  }

  bool removeItem(String site, BuildContext context) {
    final status = _items.remove(site);
    if (status) {
      _db.removeItem(context, site);
      _update();
    }
    return status;
  }

  // Feed
  updateTime(String site, int time, BuildContext context) {
    if (feed.containsKey(site))
      _feed[site] += time;
    else
      _feed[site] = time;
    _db.updateTime(context, site, time);
    _update();
  }

  // Settings
  updateSetting(String category, bool state) {
    assert(_settings.containsKey(category),
        'Category not found in settings: $category');
    _settings[category] = state;
    // If all are false, set them to true
    if (!_settings.values.contains(true))
      settings.updateAll((key, value) => true);
    _update();
  }
}
