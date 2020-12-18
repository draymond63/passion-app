import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/helpers/firebase.dart';

// * Interface for user file
class Storage extends ChangeNotifier {
  final _db = DBService();
  // data
  Settings _settings;
  Map<String, int> _feed;
  List<String> _items;

  Storage({Settings settings, Map feed, List items}) {
    // ! NEED A BETTER WAY TO DEEP COPY
    _settings = settings;
    _feed = feed.cast<String, int>();
    _items = items.cast<String>();
  }

  factory Storage.fromMap(Map map) {
    return Storage(
      settings: Settings.fromMap(map),
      items: map['items'] ?? [], // 'LeBron_James'
      feed: map['feed'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'settings': settings.toMap(),
      'items': items,
      'feed': feed,
    };
  }

  // * GETTERS
  Settings get settings => _settings;
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
  updateCategory(String key, bool state) {
    assert(_settings.category.containsKey(key),
        'Category setting not found: $key');
    _settings.category[key] = state;
    // If all are false, set them to true
    if (!settings.category.containsValue(true))
      _settings.category.updateAll((key, value) => true);
    _update();
  }

  updateData(String key, bool state) {
    assert(_settings.data.containsKey(key), 'Setting not found: $key');
    _settings.data[key] = state;
    _update();
  }

  deleteData(context) {
    _feed = {};
    _items = [];
    _db.deleteData(context);
    _update();
  }
}

class Settings {
  Map<String, bool> _category;
  Map<String, bool> _data;

  Settings({category, data}) {
    _category = Map.from(category);
    _data = Map.from(data);
  }

  factory Settings.fromMap(Map map) {
    return Settings(
      category: map['category'] ??
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
      data: map['data'] ??
          {
            'show_image': true,
          },
    );
  }

  Map toMap() {
    return {'category': category, 'data': data};
  }

  Map<String, bool> get category => _category;
  Map<String, bool> get data => _data;
}
