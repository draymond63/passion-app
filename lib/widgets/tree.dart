import 'package:PassionFruit/helpers/firebase.dart';
import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/widgets/treeNode.dart';
import 'package:flutter/cupertino.dart';
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
  List<int> selected;
  List<PageController> _swipers =
      List.generate(6, (i) => PageController(viewportFraction: 0.3));

  initState() {
    super.initState();
    // _swipers = List.generate(
    //     _columns.length, (i) => PageController(viewportFraction: 0.3));
    selected = List.filled(_columns.length, 0);

    // Listen to each swipe page
    for (int i = 0; i < _columns.length; i++) {
      _swipers[i].addListener(() {
        final page = _swipers[i].page.round();
        if (selected[i] != page) setState(() => selected[i] = page);
      });
    }
  }

  /* Initialize map from vitals and user data
   *  {
   *    VitCol.l0: [
   *      {
   *        'name: 'People',
   *        'children': ['l1-child1', 'l1-child2', ...]
   *        'count': 12 // ! NOT ADDED
   *      },
   *      {
   *        'name': 'History',
   *        'children': [...]
   *      }
   *      ...
   *    ],
   *    VitCol.l1: [
   *      {
   *        'name': 'l1-child1',
   *        'children': [...]
   *      }
   *      ...
   *    ]
   *    ...
   *    VitCol.name: [
   *      {
   *        'name': 'item1', // Name map won't have any children in its lists
   *        'children': []
   *      }
   *      ...
   *    ]
   *  }
   */
  Map<VitCol, List<Map>> getTreeData(List<List> csv, List items) {
    // For future loading
    if (csv.length == 0) return {};
    // Strip vitals down to liked items
    final data =
        csv.where((row) => items.contains(row[VitCol.site.index])).toList();

    Map<VitCol, List<Map>> tree =
        Map.fromIterable(_columns, key: (col) => col, value: (_) => []);

    // Set up l0s because they are a special case
    VitCol parentCol = _columns[0];
    final l0s =
        data.map((row) => row[parentCol.index] as String).toSet().toList();
    tree[parentCol] = l0s.map((l0) => {'name': l0, 'children': []}).toList();
    // Iterate through each column
    List<String> addedItems = [];
    List<String> parents = l0s;
    for (final col in _columns.skip(1)) {
      // Iterate through each item in the data
      for (final row in data) {
        final String item = row[col.index];
        if (!addedItems.contains(item)) {
          tree[col].add({'name': item, 'children': []});
          // Add item to parent's children
          final parentName = row[parentCol.index];
          final pIndex = parents.indexOf(parentName);
          tree[parentCol][pIndex]['children'].add(item);
          // Keep track of the items we added
          addedItems.add(item);
        }
      }
      parentCol = col;
      parents = addedItems;
      addedItems = [];
    }
    return tree;
  }

  // Gets list using the selected items from the parents
  List getItems(Map<VitCol, List<Map>> treeData, int index) {
    // Get all items that are at that level
    if (index == 0) {
      // First column doesn't have parents
      final column = _columns[index];
      return treeData[column].map((item) => item['name'] as String).toList();
    } else {
      // Get parent's children
      final parentCol = _columns[index - 1];
      final sPIndex = selected[index - 1];
      final parent = treeData[parentCol][sPIndex];
      return parent['children'];
    }
  }

  // * Builds the rendered tree
  Widget buildTree(Map<VitCol, List<Map>> treeData) {
    // return Text(treeData.toString());
    return Container(
      height: 500,
      child: ListView(
          children: List<Widget>.generate(_columns.length, (r) {
        final items = getItems(treeData, r);
        return PageView(
            controller: _swipers[r],
            children: List<Widget>.generate(
              items.length,
              (i) => TreeNode(items[i]),
            ));
      })),
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
                return buildTree(getTreeData(vitals.data, snap.data.items));
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
