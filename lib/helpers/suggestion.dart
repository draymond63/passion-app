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
    final validSuggestions = vitals
        .where((row) =>
            !userInfo.containsKey(row[siteCol]) &&
            settings[row[VitCol.l0.index]])
        .toList();

    final infoRows =
        vitals.where((row) => userInfo.containsKey(row[siteCol])).toList();

    // ? IMPROVE EFFICIENCY BY SELECTING ALL SITES TOGETHER ?
    final sites = <String>[];
    for (int ii = 0; ii < k; ii++) {
      // Create a new instance that will get filtered
      List<List> rows = validSuggestions;
      for (final col in columns) {
        // Get the options for this column
        final options = getOptions(col, rows);
        // Get the weights for each option
        Map<String, double> probs =
            getWeights(col, userInfo, options, infoRows);
        // If some options have never been seen, give them a chance
        adjustWeights(col, probs, options);
        // Choose an option!
        final selection = randomChoice(probs.keys, probs.values);
        // Keep rows with the selection
        rows = rows.where((r) => r[col.index] == selection).toList();
        if (rows.length == 0)
          throw Exception('Suggestion Selection not found: $selection');
      }
      final site = randomChoice<String>(rows.map((r) => r[siteCol]));
      sites.add(site);
      // Remove site from future suggestions
      validSuggestions.removeWhere((row) => row[siteCol] == site);
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

  List<String> getOptions(VitCol col, List<List> rows) {
    return rows.map((row) => row[col.index] as String).toSet().toList();
  }

  Map<String, double> getWeights(
      VitCol col, Map info, List<String> options, List<List> infoRows) {
    // Get all categories that have been seen
    final probs = <String, double>{};

    for (final site in info.keys) {
      final row = infoRows.firstWhere((r) => r[siteCol] == site).toList();
      final category = row[col.index];
      if (options.contains(category)) {
        if (!probs.containsKey(category)) probs[category] = 0;
        probs[category] += info[site].toDouble();
      }
    }
    return probs; // Normalization is not required
  }

  void adjustWeights(VitCol col, Map probs, List<String> options) {
    double mean = 0;
    if (probs.length != 0) {
      probs.forEach((key, value) => mean += value);
      mean /= probs.length;
    } else {
      mean = 1;
    }

    options.forEach((opt) {
      if (!probs.containsKey(opt)) probs[opt] = mean;
    });
  }
}
