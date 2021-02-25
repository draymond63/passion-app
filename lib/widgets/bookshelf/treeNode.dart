import 'package:PassionFruit/helpers/globals.dart';
import 'package:flutter/material.dart';

class TreeNode extends StatelessWidget {
  final String site;
  final int count;
  final bool showArrow;
  TreeNode(this.site, this.count, this.showArrow);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: boxShadow,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width - 85, // Prevents overlap
            child: Text(
              site.replaceAll('_', ' '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ItemSubtitle,
            ),
          ),
          if (showArrow)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Right align arrow
                Text('$count'),
                Icon(Icons.arrow_right_rounded),
              ],
            ),
        ],
      ),
    );
  }
}
