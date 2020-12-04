import 'package:PassionFruit/helpers/firebase.dart';
import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/widgets/bookshelf/treeNode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TreeViewer extends StatefulWidget {
  @override
  _TreeViewerState createState() => _TreeViewerState();
}

class _TreeViewerState extends State<TreeViewer> {
  // Each row of the tree represents one of the columns in this list
  final _columns = [
    VitCol.l0,
    VitCol.l1,
    VitCol.l2,
    VitCol.l3,
    VitCol.l4,
    VitCol.name
  ];
  int depth = 0; // How many layers deep the tree is showing (0-5)
  List<String> path = []; // Current route to items
  List<List> data = [[]];

  // * Updates user data and initialization
  void buildTreeData(List<List> csv, List items) {
    // For future loading
    if (csv.length == 0) return;
    // Strip vitals down to liked items
    data = csv.where((row) => items.contains(row[VitCol.site.index])).toList();
  }

  List getItems() {
    Iterable trim = data;
    // Strip vitals down to children of the parent (path.last)
    if (depth != 0)
      trim = trim.where((row) => row[_columns[depth - 1].index] == path.last);
    // Get the appriorate column
    trim = trim.map((row) => row[_columns[depth].index]);
    // Get a unique list
    return trim.toSet().toList();
  }

  // * Updates tree depth and associated items
  void selectBranch(String selection) {
    if (depth != _columns.length - 1) {
      // Update state
      setState(() => path.add(selection));
      setState(() => depth++);
      // Dive deeper into the tree if there's only one child
      final children = getItems();
      if (children.length == 1) selectBranch(children.first);
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
  List<Widget> buildTree(List items, BuildContext context) {
    return [
      Align(
        alignment: Alignment.topLeft,
        child: Text('Your Tree', style: ItemHeader),
      ),
      // * ITEMS
      ...List.generate(
        items.length,
        (i) => InkWell(
          onTap: () => selectBranch(items[i]),
          child: TreeNode(items[i], depth != _columns.length - 1),
        ),
      ),
      // * PATH
      FittedBox(
          child: path.length > 0
              // ! PATH ORDER NOT GUARANTEED WITH SET
              ? Text(path.toSet().join(' -> ').replaceAll('_', ' '))
              : Container(width: 1, height: 1)),
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
    final vitals = Provider.of<List<List>>(context);
    final user = Provider.of<User>(context);
    buildTreeData(vitals, user.items);

    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: buildTree(getItems(), context),
      ),
    );
  }
}
