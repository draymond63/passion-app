import 'package:flutter/material.dart';
import '../globals.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic> settings = {
    'People': true,
    'History': true,
    'Geography': true,
    'Arts': true,
    'Social Sciences': true,
    'Biology': true,
    'Physical Sciences': true,
    'Technology': true,
    'Mathematics': true,
  };

  @override
  _SettingsPageState() {
    readUserFile().then((data) {
      if (data == null)
        throw Exception("Datafile doesn't exist");
      else
        setState(() => settings = data['settings']);
    });
  }

  // Save setting
  void saveSetting(String option, bool state) async {
    print(option + state.toString() + settings[option].toString());
    // Write to state
    setState(() => settings[option] = state);
    // Write to file
    var obj = await readUserFile();
    obj['settings'][option] = state;
    writeUserFile(obj);
  }

  List<Widget> buildSettings() {
    List<Widget> widgList = [];
    settings.forEach((opt, state) {
      widgList.add(Row(children: [
        Text(opt, style: Theme.of(context).textTheme.headline2),
        Expanded(child: SizedBox()), // Fils space inbetween
        Switch(value: state, onChanged: (state) => saveSetting(opt, state))
      ]));
    });
    return widgList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: new EdgeInsets.all(20.0),
        child: ListView(
          children: [
            Text('Categories', style: Theme.of(context).textTheme.headline1),
            Text('Decide which type of topics can be suggested',
                style: Theme.of(context).textTheme.bodyText1),
            Column(children: buildSettings()),
            Text('Lesson Frequency',
                style: Theme.of(context).textTheme.headline1),
            Text('How often should we suggest topics',
                style: Theme.of(context).textTheme.bodyText1),
          ],
        ));
  }
}
