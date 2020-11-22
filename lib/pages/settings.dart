import 'package:flutter/material.dart';
import '../globals.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic> settings = {
    'categories': {
      'People': true,
      'History': true,
      'Geography': true,
      'Arts': true,
      'Social Sciences': true,
      'Biology': true,
      'Physical Sciences': true,
      'Technology': true,
      'Mathematics': true,
    },
    'lesson-frequency': 5
  };

  @override
  _SettingsPageState() : super() {
    readUserFile().then((data) => setState(() => settings = data['settings']));
  }

  // Save setting
  void saveSetting(String section, String option, bool state) async {
    // Write to state
    setState(() => settings[section][option] = state);
    // Write to file
    editUserFile((data) {
      data['settings'][section][option] = state;
    });
  }

  List<Widget> buildCategorySettings() {
    List<Widget> widgList = [];
    settings['categories'].forEach((opt, state) {
      widgList.add(Row(children: [
        Text(opt, style: Theme.of(context).textTheme.headline2),
        Expanded(child: SizedBox()), // Fils space inbetween
        Switch(
            value: state,
            onChanged: (state) => saveSetting('categories', opt, state))
      ]));
    });
    return widgList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: new EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            Text('Categories', style: Theme.of(context).textTheme.headline1),
            Text('Decide which type of topics can be suggested',
                style: Theme.of(context).textTheme.bodyText1),
            Column(children: buildCategorySettings()),
            Text('Lesson Frequency',
                style: Theme.of(context).textTheme.headline1),
            Text(settings['lesson-frequency'].toString()),
            Text('How often should we suggest topics',
                style: Theme.of(context).textTheme.bodyText1),
            IconButton(
                icon: Icon(Icons.sanitizer),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => Text('hi'))))
          ],
        ));
  }
}
