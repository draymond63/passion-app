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
    vitals = Provider.of<Map>(context);
  }

  Future<String> suggest() async {
    if (vitals.length == 0) return ''; // Null safety
    final store = Provider.of<Storage>(context);
    final settings = store.settings;
    // Remove all entries that don't want to be seen
    final userInfo = trimData(store.feed, settings);

    // Remove all rows that have been seen or are ignored by user settings
    final rows = {...vitals};
    rows.removeWhere((key, row) =>
        userInfo.containsKey(key) || !settings.category[row['l0']]);

    for (final col in columns) {
      // Get the options for this column
      final options = getOptions(col, rows);
      // Get the weights for each option
      Map<String, double> probs = getWeights(col, userInfo, options);
      // If some options have never been seen, give them a chance
      adjustWeights(probs, options);
      // Choose an option!
      final selection = randomChoice(probs.keys, probs.values);
      // Keep rows with the selection
      rows.removeWhere((_, r) => r[col] != selection);
      if (rows.length == 0)
        throw Exception('Suggestion Selection not found: $selection');
    }
    return randomChoice<String>(rows.keys.cast<String>());
  }

  Map<String, int> trimData(Map<String, int> info, Settings settings) {
    final userInfo = <String, int>{};
    info.forEach((key, value) {
      final row = vitals[key];
      if (settings.category[row['l0']]) userInfo[key] = value;
    });
    return userInfo;
  }

  List<String> getOptions(String col, Map rows) {
    return rows.values.map((row) => row[col] as String).toSet().toList();
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

  void adjustWeights(Map probs, List<String> options) {
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
