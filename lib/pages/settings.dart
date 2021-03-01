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
  Settings settings = Settings(category: {}, data: {});

  @override
  void initState() {
    super.initState();
    Future.microtask(() => setState(() =>
        settings = Provider.of<Storage>(context, listen: false).settings));
  }

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
            ...buildCategorySettings(),
            Text('Data Settings', style: Theme.of(context).textTheme.headline1),
            Text('Manage your data the way you want',
                style: Theme.of(context).textTheme.bodyText1),
            ...buildDataSettings(),
          ],
        ),
      ),
    );
  }

  List<Widget> buildCategorySettings() {
    // Parsing of settings
    final categories = settings.category;
    final opts = categories.keys.toList();
    final states = categories.values.toList();
    // Render
    return List<Widget>.generate(
      categories.length,
      (i) => SwitchListTile.adaptive(
        title: Text(
          opts[i].replaceAll('_', ' '),
          style: Theme.of(context).textTheme.headline2,
        ),
        value: states[i] ?? true,
        onChanged: (newState) => updateCategory(opts[i], newState),
      ),
    );
  }

  List<Widget> buildDataSettings() => [
        SwitchListTile.adaptive(
          title: Text(
            'Show Images',
            style: Theme.of(context).textTheme.headline2,
          ),
          value: settings.data['show_image'] ?? true,
          onChanged: (b) => updateData('show_image', b),
        ),
        SwitchListTile.adaptive(
          title: Text(
            'Send data for app improvement',
            style: Theme.of(context).textTheme.headline2,
          ),
          value: settings.data['send_data'] ?? true,
          onChanged: (b) => updateDataTransmission(b),
        ),
        FlatButton(
          child: Text(
            'Delete User Profile',
            style: TextStyle(color: Colors.red[700]),
          ),
          shape: Border.all(color: Colors.red[700]),
          onPressed: showDeletionWarning,
        ),
      ];

  updateCategory(String selection, bool state) {
    final store = Provider.of<Storage>(context, listen: false);
    store.updateCategorySetting(selection, state);
    setState(() => settings.category[selection] = state); // Update widget
  }

  updateData(String selection, bool state) {
    final store = Provider.of<Storage>(context, listen: false);
    store.updateDataSetting(selection, state);
    setState(() => settings.data[selection] = state); // Update widget
  }

  updateDataTransmission(bool state) {
    // Local Settings
    updateData('send_data', state);
    // Delete data for a sync or to remove user
    final store = Provider.of<Storage>(context, listen: false);
    store.db.deleteData(context);
    if (state) store.db.syncData(context); // If statement for legability
  }

  // * Warning Screen
  void showDeletionWarning() {
    pushNewScreen(
      context,
      // withNavBar: false, // Causes weird error
      pageTransitionAnimation: PageTransitionAnimation.fade,
      screen: Material(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                FlatButton(
                  child: Text(
                    'Yes, I want to restart',
                    style: TextStyle(color: Colors.red[700]),
                  ),
                  shape: Border.all(color: Colors.red[700]),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Provider.of<Storage>(context, listen: false)
                        .deleteData(context);
                  },
                ),
                Expanded(child: Container()),
                FlatButton(
                  child: Text('No, I want to keep my data'),
                  color: Colors.green[100],
                  onPressed: Navigator.of(context).pop,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(String text, Color color, [Function() onPressed]) {
    return FlatButton(
      child: Text(text),
      shape: Border.all(color: color),
      onPressed: () {
        Navigator.of(context).pop();
        if (onPressed != null) onPressed();
      },
    );
  }
}
