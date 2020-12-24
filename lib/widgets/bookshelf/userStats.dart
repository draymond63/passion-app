import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/helpers/storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserStatistics extends StatefulWidget {
  UserStatistics();

  @override
  _UserStatisticsState createState() => _UserStatisticsState();
}

class _UserStatisticsState extends State<UserStatistics> {
  List<String> getPopularL0s(Map vitals, Storage user) {
    // Get all current l0s
    final items = user.items;
    final rows = vitals.entries.where((row) => items.contains(row.key));
    final l0s = rows.map((entry) => entry.value['l0']).toList();
    // Counts frequency
    final map = Map();
    l0s.forEach((element) =>
        map.containsKey(element) ? map[element] += 1 : map[element] = 1);
    if (map.length == 0) return [''];
    // Map to List
    final sorted = <List>[];
    map.forEach((key, value) => sorted.add([key, value]));
    // Sort by frequency
    sorted.sort((map1, map2) => map2[1].compareTo(map1[1]));
    // Return name column
    return sorted.map((row) => row[0].toString().replaceAll('_', ' ')).toList();
  }

  @override
  Widget build(BuildContext context) {
    final vitals = Provider.of<Map>(context);
    final user = Provider.of<Storage>(context);

    final popList = getPopularL0s(vitals, user);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About You', style: ItemHeader),
        popList.length > 0
            ? Text(
                'Most popular category: ' + popList[0],
                style: ItemSubtitle,
              )
            : Text('Bookmark some items to learn about yourself!')
      ],
    );
  }
}
