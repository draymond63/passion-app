import 'package:flutter/material.dart';

class TreeNode extends StatelessWidget {
  final String site = '';
  TreeNode(String site);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Text(site),
    );
  }
}
