import 'package:PassionFruit/helpers/storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dart_random_choice/dart_random_choice.dart';
// import 'package:PassionFruit/helpers/globals.dart';

class Suggestor {
  Map vitals;

  final columns = ['l0', 'l1', 'l2', 'l3', 'l4'];
  BuildContext context;

  Suggestor(this.context) {
    vitals = Provider.of<Map>(context); // ! DOESN'T CHECK IF ITS EMPTY
  }

  // ! Causes an error sometimes?
  List<String> suggest([int k = 10]) {
    if (vitals.length == 0) return []; // Null safety
    final store = Provider.of<Storage>(context);
    final settings = store.settings;
    // Remove all entries that don't want to be seen
    final userInfo = trimData(store.feed, settings);

    // ? COMBINE INTO ONE ITERATION ?
    // Remove all rows that have been seen or are ignored by user settings
    final validSuggestions = vitals.entries
        .where((row) =>
            !userInfo.containsKey(row.key) &&
            settings.category[row.value['l0']])
        .toList();

    // ? IMPROVE EFFICIENCY BY SELECTING ALL SITES TOGETHER ?
    final sites = <String>[];
    for (int ii = 0; ii < k; ii++) {
      // Create a new instance that will get filtered
      List<MapEntry> rows = validSuggestions;
      for (final col in columns) {
        // Get the options for this column
        final options = getOptions(col, rows);
        // Get the weights for each option
        Map<String, double> probs = getWeights(col, userInfo, options);
        // If some options have never been seen, give them a chance
        adjustWeights(col, probs, options);
        // Choose an option!
        final selection = randomChoice(probs.keys, probs.values);
        // Keep rows with the selection
        rows = rows.where((r) => r.value[col] == selection).toList();
        if (rows.length == 0)
          throw Exception('Suggestion Selection not found: $selection');
      }
      final site = randomChoice<String>(rows.map((r) => r.key));
      sites.add(site);
      // Remove site from future suggestions
      validSuggestions.removeWhere((row) => row.key == site);
    }
    return sites;
  }

  Map<String, int> trimData(Map<String, int> info, Settings settings) {
    final userInfo = <String, int>{};
    info.forEach((key, value) {
      final row = vitals[key];
      if (settings.category[row['l0']]) userInfo[key] = value;
    });
    return userInfo;
  }

  List<String> getOptions(String col, List<MapEntry> rows) {
    return rows.map((row) => row.value[col] as String).toSet().toList();
  }

  Map<String, double> getWeights(String col, Map info, List<String> options) {
    // Get all categories that have been seen
    final probs = <String, double>{};

    for (final site in info.keys) {
      final row = vitals[site];
      final category = row[col];
      if (options.contains(category)) {
        if (!probs.containsKey(category)) probs[category] = 0;
        probs[category] += info[site].toDouble();
      }
    }
    return probs; // Normalization is not required
  }

  void adjustWeights(String col, Map probs, List<String> options) {
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
