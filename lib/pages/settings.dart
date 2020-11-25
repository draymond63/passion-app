import 'package:flutter/material.dart';
import '../helpers/globals.dart';

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
    'allow-random': true
  };

  _SettingsPageState() {
    readUserFile().then((data) => setState(() => settings = data['settings']));
  }

  // Keeps state and userfile in sink
  bool saveSetting(List<String> path, bool state) {
    // Write to state
    setState(() => _editData(settings, path, state));
    // Write to file
    editUserFile((data) {
      _editData(data['settings'], path, state);
    });
    return state;
  }

  // follow the path to the end of the data to change the state
  void _editData(Map data, List<String> path, dynamic state) {
    dynamic temp = data;
    int index = 0;
    do {
      temp = temp[path[index]];
      index++;
    } while (index < path.length - 1);
    temp[path.last] = state;
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
            ...buildCategorySettings(),
            Text('Misc', style: Theme.of(context).textTheme.headline1),
            buildSwitch('Random Suggestions', ['allow-random'],
                settings['allow-random'])
          ],
        ));
  }

  Widget buildSwitch(String title, List<String> path, bool state) {
    return SwitchListTile(
        title: Text(title, style: Theme.of(context).textTheme.headline2),
        value: state,
        onChanged: (newState) => saveSetting(path, newState));
  }

  List<Widget> buildCategorySettings() {
    List<Widget> widgList = [];
    settings['categories'].forEach((opt, state) {
      widgList.add(buildSwitch(opt, ['categories', opt], state));
    });
    return widgList;
  }
}
