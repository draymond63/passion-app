import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/helpers/firebase.dart';

// * Interface for user file
class Storage extends ChangeNotifier {
  final db = DBService();
  final changeMax = 10;
  // data
  Settings _settings;
  Map<String, int> _feed;
  List<String> _items;
  bool _initUser; // True if the user needs to be onboarded
  int _changes = 0;
  // ! ASSUMES 3 PAGES
  List<DateTime> _pageStartTimes = List.filled(3, DateTime.now());
  List<DateTime> _pageEndTimes = List.filled(3, DateTime.now());

  Storage({
    Settings settings,
    Map feed,
    List items,
    bool initUser,
    int changes,
  }) {
    _settings = settings;
    _feed = feed.cast<String, int>();
    _items = items.cast<String>();
    _initUser = initUser;
    _changes = _changes;
  }

  factory Storage.fromMap(Map map) {
    return Storage(
      settings: Settings.fromMap(map),
      items: map['items'] ?? [], // 'LeBron_James'
      feed: map['feed'] ?? {},
      initUser: map['initd'] ?? true,
      changes: map['changes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'settings': settings.toMap(),
      'items': items,
      'feed': feed,
      'initd': initUser,
      'changes': _changes,
    };
  }

  // * GETTERS
  Settings get settings => _settings;
  List<String> get items => _items;
  Map<String, int> get feed => _feed;
  bool get initUser => _initUser;

  set initUser(bool v) {
    _initUser = v;
    _update();
  }

  DateTimeRange getPageStamps(int index) =>
      DateTimeRange(start: _pageStartTimes[index], end: _pageEndTimes[index]);

  // * FUNCTIONS
  // context: passed if value should be synced
  // quiet: whether to trigger a rerender
  void _update({BuildContext context, bool quiet = true}) {
    if (!quiet) notifyListeners();
    // Update database is enough changes have accumulated
    _changes++;
    if (_changes >= changeMax && context != null) db.syncData(context);
    _changes %= changeMax;
    // Write to local storage
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
      _update(context: context, quiet: false);
      return true;
    }
    return false;
  }

  bool removeItem(String site, BuildContext context) {
    final status = _items.remove(site);
    if (status) {
      _update(context: context, quiet: false);
    }
    return status;
  }

  // Feed
  void updateTime(String site, int time, BuildContext context) {
    if (feed.containsKey(site))
      _feed[site] += time;
    else
      _feed[site] = time;
    _update(context: context);
  }

  void timeStampPage({int oldPage, int newPage}) {
    final timeStamp = DateTime.now();
    if (newPage != null) _pageStartTimes[newPage] = timeStamp;
    if (oldPage != null) _pageEndTimes[oldPage] = timeStamp;
  }

  // Settings
  void updateCategorySetting(String key, bool state) {
    assert(_settings.category.containsKey(key),
        'Category setting not found: $key');
    _settings.category[key] = state;
    // If all are false, set them to true
    if (!settings.category.containsValue(true))
      _settings.category.updateAll((key, value) => true);
    _update();
  }

  void updateDataSetting(String key, bool state) {
    assert(_settings.data.containsKey(key), 'Setting not found: $key');
    _settings.data[key] = state;
    _update(quiet: false);
  }

  void deleteData(context) {
    _feed = {};
    _items = [];
    db.deleteData(context);
    _update(quiet: false);
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
            'send_data': true,
          },
    );
  }

  Map toMap() {
    return {'category': category, 'data': data};
  }

  Map<String, bool> get category => _category;
  Map<String, bool> get data => _data;
}
