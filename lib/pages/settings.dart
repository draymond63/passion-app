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
        TextButton(
          onPressed: () => showDeletionWarning(),
          child: Text('Delete User Profile'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
        )
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
