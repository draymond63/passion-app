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
    final temp = csv.entries.where((row) => items.contains(row.key)).toList();
    // If a difference in length occurs, reset the tree
    if (temp.length != data.length) {
      data = temp;
      path = [];
      setState(() => depth = 0); // Trigger rerender
    }
  }

  Map<String, int> getItems([iDepth]) {
    if (iDepth == null) iDepth = depth;
    Iterable trim = data;
    // Strip vitals down to children of the parent (path.last)
    if (iDepth != 0)
      trim = trim.where((row) => row.value[_columns[iDepth - 1]] == path.last);
    // Get the appriorate column (site if we are at the end)
    if (iDepth == _columns.length - 1)
      trim = trim.map((row) => row.key);
    else
      trim = trim.map((row) => row.value[_columns[iDepth]]);
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
  Widget buildTree() {
    final items = getItems();
    // sites & counts might not be in sync, but sorting them will make it right
    final sites = items.keys.toList();
    final counts = items.values.toList();
    // Sort in descending order by value
    counts.sort((a, b) => b - a);
    sites.sort((k1, k2) => items[k2] - items[k1]);

    return Column(children: [
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
      if (path.length > 0)
        FittedBox(
          // ! PATH ORDER NOT GUARANTEED WITH SET
          child: Text(path.toSet().join(' -> ').replaceAll('_', ' ')),
        ),
      // * Back button
      if (depth != 0)
        RawMaterialButton(
          onPressed: popBranch,
          elevation: 2.0,
          fillColor: Colors.white,
          child: Icon(Icons.arrow_back_ios_rounded),
          padding: EdgeInsets.all(15.0),
          shape: CircleBorder(),
        )
    ]);
  }

  // * Builds the data
  @override
  Widget build(BuildContext context) {
    final vitals = Provider.of<Map>(context);
    final user = Provider.of<Storage>(context);
    buildTreeData(vitals, user.items);

    return Container(
      width: MediaQuery.of(context).size.width,
      // Keep tree a constant size
      // ! MEASURED CONSTANT
      constraints: BoxConstraints(minHeight: getItems(0).length * 68.0),
      child: buildTree(),
    );
  }
}
