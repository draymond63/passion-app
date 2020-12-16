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
    vitals = Provider.of<List<List>>(context);
  }

  // ! Causes an error sometimes?
  List<String> suggest([int k = 10]) {
    final store = Provider.of<Storage>(context);
    final userInfo = store.feed;
    final settings = store.settings;
    // If we don't have any data, return the random sites
    if (userInfo.length == 0)
      return List.generate(k, (_) => randomChoice(vitals)[siteCol]);

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
        final probs = getWeights(col, userRows, rows, userInfo);
        print(col);
        print(probs);
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

  Map<String, double> getWeights(
      VitCol col, List<List> user, List<List> rows, Map info) {
    // Get all categories that have been seen
    final probs = <String, double>{};
    double total = 0;

    for (final site in info.keys) {
      final row =
          user.firstWhere((r) => r[siteCol] == site, orElse: () => []).toList();
      // ? Is this necessary ?
      if (row.length != 0) {
        final category = row[col.index];
        if (!probs.containsKey(category)) probs[category] = 0;
        probs[category] += info[site].toDouble();
        total += info[site];
      }
    }
    if (total == 0) {
      for (final category in rows.map((r) => r[col.index])) probs[category] = 1;
      return probs;
    }
    // Set unseen categories to the mean (if they are still in "rows")
    for (final category in rows.map((r) => r[col.index]))
      if (!probs.containsKey(category)) probs[category] = total / probs.length;
    return probs; // Normalization is not required
  }
}
