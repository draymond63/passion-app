import 'package:PassionFruit/helpers/globals.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:provider/provider.dart';
import 'package:PassionFruit/helpers/storage.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Container(
        padding: new EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            Text('Categories', style: Theme.of(context).textTheme.headline1),
            Text('Decide which type of topics can be suggested',
                style: Theme.of(context).textTheme.bodyText1),
            ...buildCategorySettings(context),
            Text('Data Settings', style: Theme.of(context).textTheme.headline1),
            Text('Manage your data the way you want',
                style: Theme.of(context).textTheme.bodyText1),
            ...buildDataSettings(context),
          ],
        ),
      ),
    );
  }

  List<Widget> buildCategorySettings(BuildContext context) {
    final store = Provider.of<Storage>(context);
    final settings = store.settings.category;
    final opts = settings.keys.toList();
    final states = settings.values.toList();
    return List<Widget>.generate(
      settings.length,
      (i) => SwitchListTile.adaptive(
        title: Text(
          opts[i].replaceAll('_', ' '),
          style: Theme.of(context).textTheme.headline2,
        ),
        value: states[i],
        onChanged: (newState) => store.updateCategory(opts[i], newState),
      ),
    );
  }

  List<Widget> buildDataSettings(BuildContext context) {
    final store = Provider.of<Storage>(context);
    return [
      SwitchListTile.adaptive(
        title: Text(
          'Show Images',
          style: Theme.of(context).textTheme.headline2,
        ),
        value: store.settings.data['show_image'],
        onChanged: (newState) => store.updateData('show_image', newState),
      ),
      SwitchListTile.adaptive(
        title: Text(
          'Send data for app improvement',
          style: Theme.of(context).textTheme.headline2,
        ),
        value: store.settings.data['send_data'],
        onChanged: (newState) => updateDataTransmission(newState, context),
      ),
      TextButton(
        onPressed: () => showDeletionWarning(context),
        child: Text('Delete User Profile'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
      )
    ];
  }

  updateDataTransmission(bool state, BuildContext context) {
    final store = Provider.of<Storage>(context, listen: false);
    store.db.deleteData(context); // Delete data for a sync or to remove user
    store.updateData('send_data', state); // Update local settings
    if (state) store.db.syncData(context); // If statement for legability
  }

  // Warning Screen
  void showDeletionWarning(BuildContext context) {
    pushNewScreen(
      context,
      screen: Material(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Are you sure you want to delete all your data?',
            style: ItemHeader,
            textAlign: TextAlign.center,
          ),
          Text(
            'This will give you a fresh start',
            style: ItemSubtitle,
            textAlign: TextAlign.center,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            buildButton(
              'Yes',
              Colors.red,
              () => Provider.of<Storage>(context, listen: false)
                  .deleteData(context),
            ),
            buildButton('No', Colors.green),
          ]),
        ],
      )),
    );
  }

  Widget buildButton(String text, Color color, [Function() onPressed]) {
    return Expanded(
      child: TextButton(
        child: Text(text),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(color),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        onPressed: () {
          Navigator.of(context).pop();
          if (onPressed != null) onPressed();
        },
      ),
    );
  }
}
