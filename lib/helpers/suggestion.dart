import 'package:PassionFruit/helpers/storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:PassionFruit/helpers/globals.dart';

class Suggestor {
  List<List> vitals;

  final siteCol = VitCol.site.index;
  final columns = [
    VitCol.l0,
    VitCol.l1,
    VitCol.l2,
    VitCol.l3,
    VitCol.l4,
  ];
  BuildContext context;

  Suggestor(this.context) {
    vitals = Provider.of<List<List>>(context); // ! DOESN'T CHECK IF ITS EMPTY
  }

  // ! Causes an error sometimes?
  List<String> suggest([int k = 10]) {
    final store = Provider.of<Storage>(context);
    final settings = store.settings;
    // Remove all entries that don't want to be seen
    final userInfo = trimData(store.feed, settings);

    // ? COMBINE INTO ONE ITERATION ?
    // Remove all rows that have been seen or are ignored by user settings
    final rowsConst = vitals
        .where((row) =>
            !userInfo.containsKey(row[siteCol]) &&
            settings[row[VitCol.l0.index]])
        .toList();
    final userConst =
        vitals.where((row) => userInfo.containsKey(row[siteCol])).toList();

    // ? IMPROVE EFFICIENCY BY SELECTING ALL SITES TOGETHER ?
    final sites = <String>[];
    for (int ii = 0; ii < k; ii++) {
      // Create a new instance that will get filtered
      List<List> rows = rowsConst;
      List<List> userRows = userConst;
      for (final col in columns) {
        Map<String, double> probs = getWeights(col, userInfo, userRows);
        // Add columns to probs that have never been seen (pass by reference)
        adjustWeights(col, probs, rows);
        // Choose an option!
        final selection = randomChoice(probs.keys, probs.values);
        // Keep rows with the selection
        rows = rows.where((r) => r[col.index] == selection).toList();
        // Filter out user data that's not relevant anymore
        userRows = userRows.where((r) => r[col.index] == selection).toList();
        if (rows.length == 0)
          throw Exception('Suggestion Selection not found: $selection');
      }
      final site = randomChoice<String>(rows.map((r) => r[siteCol]));
      sites.add(site);
    }
    return sites;
  }

  Map<String, int> trimData(Map<String, int> info, Map<String, bool> settings) {
    final userInfo = <String, int>{};
    info.forEach((key, value) {
      final row = vitals.firstWhere((row) => row[siteCol] == key);
      if (settings[row[VitCol.l0.index]]) userInfo[key] = value;
    });
    return userInfo;
  }

  Map<String, double> getWeights(VitCol col, Map info, List<List> userRows) {
    // Get all categories that have been seen
    final probs = <String, double>{};

    for (final site in info.keys) {
      final row = userRows
          .firstWhere((r) => r[siteCol] == site, orElse: () => [])
          .toList();
      // Because userRows gets trimmed in every iteration,
      // sometimes it won't find the site
      if (row.length != 0) {
        final category = row[col.index];
        if (!probs.containsKey(category)) probs[category] = 0;
        probs[category] += info[site].toDouble();
      }
    }
    return probs; // Normalization is not required
  }

  void adjustWeights(VitCol col, Map probs, List<List> rows) {
    double mean = 0;
    if (probs.length != 0) {
      probs.forEach((key, value) => mean += value);
      mean /= probs.length;
    } else {
      mean = 1;
    }

    rows.forEach((row) {
      final category = row[col.index];
      if (!probs.containsKey(category)) probs[category] = mean;
    });
  }
}
