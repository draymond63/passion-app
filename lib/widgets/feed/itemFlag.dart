import 'package:flutter/material.dart';
import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/helpers/firebase.dart';

class FlagItemPage extends StatefulWidget {
  final String site;
  FlagItemPage(this.site);
  @override
  _FlagItemPageState createState() => _FlagItemPageState();
}

class _FlagItemPageState extends State<FlagItemPage> {
  final db = DBService();
  final problems = [
    "Topic doesn't make sense",
    "Content isn't properly displaying",
    "Topic is inappropriate",
    "Other",
  ];
  Map _states;
  String _otherText;

  @override
  void initState() {
    super.initState();
    _states = Map.fromIterable(problems, value: (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop()),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("What's wrong with this topic?", style: ItemHeader),
          for (final text in problems)
            CheckboxListTile(
                title: Text(text),
                value: _states[text],
                controlAffinity: ListTileControlAffinity.platform,
                onChanged: (b) => setState(() => _states[text] = b)),
          // Other option
          if (_states['Other'])
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                onChanged: (value) => _otherText = value,
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "What's wrong?",
                ),
              ),
            ),
          // Send button
          TextButton(
            child: Text('Notify Us!'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).primaryColor),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            onPressed: () => sendError(context),
          )
        ],
      ),
    );
  }

  void sendError(context) {
    if (_states['Other']) _states['Other'] = _otherText;
    db.sendFlag(context, widget.site, _states);
    // Scaffold.of(context).showSnackBar(SnackBar(
    //   backgroundColor: Color(MAIN_ACCENT_COLOR),
    //   content: Text('Thank you for the help!'),
    // ));
    Navigator.of(context).pop();
  }
}
