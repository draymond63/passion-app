// import 'package:PassionFruit/helpers/globals.dart';
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
  final _columns = <String>['l0', 'l1', 'l2', 'l3', 'l4', 'site'];
  final _swiper = ScrollController();
  Map data;
  List<String> path = [];
  int skipped = 0;

  @override
  void dispose() {
    super.dispose();
    _swiper.dispose();
  }

  // * Builds the data
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Storage>(context);
    data = Map.from(Provider.of<Map>(context));
    data.removeWhere((key, _) => !user.items.contains(key));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Interests', style: ItemHeader),
      Container(
        height: getItems(0).length * 68.0,
        child: ListView.builder(
          controller: _swiper,
          physics: NeverScrollableScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, int page) {
            final items = getItems(page);
            // final items = getPathItems(page);
            final names = items.keys.toList();
            final counts = items.values.toList();
            // Sort the tree nodes
            counts.sort((a, b) => b - a);
            names.sort((k1, k2) => items[k2] - items[k1]);

            return Container(
              width: MediaQuery.of(context).size.width - 32,
              margin: EdgeInsets.only(left: 8, right: 24),
              child: Column(
                children: List.generate(
                  names.length,
                  (i) => InkWell(
                    child: TreeNode(
                        names[i], counts[i], page != _columns.length - 1),
                    onTap: () => pressNode(context, names[i], page),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      Text(path.join(' -> ').replaceAll('_', ' ') ?? ''),
    ]);
  }

  Map<String, int> getItems(int page) {
    if (page < 0) throw Exception('Page was less than 0');
    if (page > path.length) return {};
    final items = Map.from(data);

    for (int i = 0; i < page; i++) {
      final col = _columns[i];
      final parent = path[i];
      items.removeWhere((site, info) => info[col] != parent);
    }

    // Return the sites if we are at the end
    if (page == _columns.length - 1)
      return Map.fromIterable(
        items.keys.toList(),
        key: (i) => i,
        value: (_) => 1,
      );

    // Get the right columns of data
    final names = items.values.map((info) => info[_columns[page]]).toList();
    // Count each entry
    final count = <String, int>{};
    names.forEach((i) => count.containsKey(i) ? count[i]++ : count[i] = 1);
    return count;
  }

  // Map<String, int> getPathItems(int page) {
  //   Map items = getItems(page + skipped);
  //   while (items.length == 1 && path.length != _columns.length) {
  //     path.add(items.keys.first);
  //     skipped++;
  //     items = getItems(path.length - 1); // Get latest items
  //   }
  //   print(path);
  //   return items;
  // }

  // * TAP FUNCTIONS
  void pressNode(BuildContext context, String name, int page) {
    if (page != _columns.length - 1)
      pushBranch(context, name, page + 1);
    else
      pushNewScreen(
        context,
        screen: ViewItem(name),
        withNavBar: false,
        pageTransitionAnimation: PageTransitionAnimation.fade,
      );
  }

  void pushBranch(BuildContext context, String name, int newPage) {
    setState(() => path.add(name));
    goToBranch(newPage);
  }

  void popBranch(BuildContext context, String name, int newPage) {
    setState(() => path.removeLast());
    goToBranch(newPage);
  }

  void goToBranch(int newPage) {
    final width = MediaQuery.of(context).size.width;
    _swiper.animateTo(
      newPage * width,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOutQuad,
    );
  }
}
