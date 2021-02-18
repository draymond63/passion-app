import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/helpers/storage.dart';
import 'package:PassionFruit/widgets/bookshelf/treeNode.dart';
import 'package:PassionFruit/widgets/feed/itemView.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';

class TreeViewer extends StatefulWidget {
  @override
  _TreeViewerState createState() => _TreeViewerState();
}

class _TreeViewerState extends State<TreeViewer> {
  // Each row of the tree represents one of the columns in this list
  final _columns = ['l0', 'l1', 'l2', 'l3', 'l4', 'name'];
  int depth = 0; // How many layers deep the tree is showing (0-5)
  List<String> path = []; // Current route to items
  List<MapEntry> data = [];

  // * Updates user data and initialization
  void buildTreeData(Map csv, List items) {
    // For future loading
    if (csv.length == 0) return;
    // Strip vitals down to liked items
    data = csv.entries.where((row) => items.contains(row.key)).toList();
  }

  Map<String, int> getItems() {
    Iterable trim = data;
    // Strip vitals down to children of the parent (path.last)
    if (depth != 0)
      trim = trim.where((row) => row.value[_columns[depth - 1]] == path.last);
    // Get the appriorate column (site if we are at the end)
    if (depth == _columns.length - 1)
      trim = trim.map((row) => row.key);
    else
      trim = trim.map((row) => row.value[_columns[depth]]);
    // Count each entry
    final count = <String, int>{};
    trim.forEach(
      (i) => count.containsKey(i) ? count[i]++ : count[i] = 1,
    );
    return count;
  }

  // * Updates tree depth and associated items
  void selectBranch(String selection, {bool firstPress = true}) {
    if (depth != _columns.length - 1) {
      // Update state
      setState(() => path.add(selection));
      setState(() => depth++);
      // Dive deeper into the tree if there's only one child
      final children = getItems();
      if (children.length == 1)
        selectBranch(children.keys.first, firstPress: false);
    } else if (firstPress == true) {
      // If user clicks on a leaf tree node
      pushNewScreen(
        context,
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.fade,
        screen: ViewItem(selection), // ! GIVEN NAME NOT SITE
      );
    }
  }

  void popBranch() {
    if (depth != 0) {
      setState(() => path = List.from(path.getRange(0, path.length - 1)));
      setState(() => depth--);
      // Go up another into the tree if there's only one child
      if (getItems().length == 1) popBranch();
    }
  }

  // * Builds the rendered tree
  List<Widget> buildTree() {
    final items = getItems();
    final sites = <String>[];
    final counts = <int>[];
    items.forEach((key, value) {
      sites.add(key);
      counts.add(value);
    });

    return [
      Align(
        alignment: Alignment.topLeft,
        child: Text('Interests', style: ItemHeader),
      ),
      // * ITEMS
      ...List.generate(
        items.length,
        (i) => InkWell(
          onTap: () => selectBranch(sites[i]),
          child: TreeNode(sites[i], counts[i], depth != _columns.length - 1),
        ),
      ),
      // * PATH
      FittedBox(
        child: path.length > 0
            // ! PATH ORDER NOT GUARANTEED WITH SET
            ? Text(path.toSet().join(' -> ').replaceAll('_', ' '))
            : Container(width: 1, height: 1),
      ),
      // * Back button
      depth != 0
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_rounded),
              onPressed: popBranch,
            )
          : Container()
    ];
  }

  // * Builds the data
  @override
  Widget build(BuildContext context) {
    final vitals = Provider.of<Map>(context);
    final user = Provider.of<Storage>(context);
    buildTreeData(vitals, user.items);

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: buildTree(),
      ),
    );
  }
}
