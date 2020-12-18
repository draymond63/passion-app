import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:PassionFruit/helpers/storage.dart';

class SettingsPage extends StatelessWidget {
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
      TextButton(
        onPressed: () => store.deleteData(context),
        child: Text('Delete User Profile'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
      )
    ];
  }
}
