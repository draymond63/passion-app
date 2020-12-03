import 'package:PassionFruit/helpers/firebase.dart';
import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/widgets/treeNode.dart';
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
  List items = []; // Items to currently show
  List<String> path = []; // Current route to items
  List<List> data = [[]];

  // * Updates user data and initialization
  List getTreeData(List<List> csv, List items) {
    // For future loading
    if (csv.length == 0) return [];
    // Strip vitals down to liked items
    data = csv.where((row) => items.contains(row[VitCol.site.index])).toList();
    return data.map((row) => row[_columns[0].index]).toSet().toList();
  }

  // * Updates tree depth and associated items
  void selectBranch(String selection) {
    if (depth != _columns.length - 1) {
      // Get rows that match the selected item at the given depth
      final rows = data.where((row) => row[_columns[depth].index] == selection);
      // Get the children of the selected item
      final next = rows.map((row) => row[_columns[depth + 1].index]).toSet();
      // Update state
      setState(() => path.add(selection));
      setState(() => depth++);
      setState(() => items = List.from(next));
    }
    // Dive deeper into the tree if there's only one child
    if (items.length == 1) selectBranch(items[0]);
  }

  void popBranch() {
    if (path.length > 1) {
      final selection = path.reversed.toList()[1]; // Get parent of parent page
      // Get rows that match the selected item at the given depth
      final rows =
          data.where((row) => row[_columns[depth - 2].index] == selection);
      // // Get the children of the selected item
      final next = rows.map((row) => row[_columns[depth - 1].index]).toSet();
      setState(() => items = List.from(next));
    } else {
      // If there is no parent parent then give back the l0s
      setState(() =>
          items = List.from(data.map((row) => row[_columns[0].index]).toSet()));
    }
    setState(() => path = List.from(path.getRange(0, path.length - 1)));
    setState(() => depth--);
    // Dive deeper into the tree if there's only one child
    if (items.length == 1) popBranch();
  }

  // * Builds the rendered tree
  Widget buildTree(List init, BuildContext context) {
    // ! WONT UPDATE ON LIKED ITEM
    if (items.length == 0) {
      items = init;
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          ...List.generate(
            items.length,
            (i) => InkWell(
              onTap: () => selectBranch(items[i]),
              child: TreeNode(items[i]),
            ),
          ),
          Text('$depth'),
          // ! FIND WIDGET THAT RESTRICTS MAX SIZE
          FittedBox(
              child: path.length > 0
                  ? Text(path.join(' -> ').replaceAll('_', ' '))
                  : Container(width: 1, height: 1)),
          // Dynamic back button
          depth != 0
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios_rounded),
                  onPressed: popBranch,
                )
              : Container()
        ],
      ),
    );
  }

  // * Builds the data
  @override
  Widget build(BuildContext context) {
    final vitals = Provider.of<Future<List<List>>>(context);

    return FutureBuilder(
      future: vitals,
      builder: (BuildContext context, AsyncSnapshot<List<List>> vitals) {
        if (vitals.hasData) {
          // We need user data as well
          return StreamBuilder(
            // ! CHANGE TO GLOBAL SUBSCRIPTION
            stream: DBService().getUserData(context),
            builder: (BuildContext context, AsyncSnapshot<User> snap) {
              if (snap.hasData)
                return buildTree(
                  getTreeData(vitals.data, snap.data.items),
                  context,
                );
              if (snap.hasError) return Text('${snap.error}');
              return Text('Loading');
            },
          );
        }
        if (vitals.hasError) return Text('${vitals.error}');
        return Text('Loading');
      },
    );
  }
}