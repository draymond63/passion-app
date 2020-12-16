import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:PassionFruit/helpers/storage.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = Provider.of<Storage>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Container(
        padding: new EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            Text('Categories', style: Theme.of(context).textTheme.headline1),
            Text('Decide which type of topics can be suggested',
                style: Theme.of(context).textTheme.bodyText1),
            ...buildCategorySettings(store, context)
          ],
        ),
      ),
    );
  }

  List<Widget> buildCategorySettings(Storage store, BuildContext context) {
    final opts = store.settings.keys.toList();
    final states = store.settings.values.toList();
    return List<Widget>.generate(
      store.settings.length,
      (i) => SwitchListTile(
        title: Text(
          opts[i].replaceAll('_', ' '),
          style: Theme.of(context).textTheme.headline2,
        ),
        value: states[i],
        onChanged: (newState) => store.updateSetting(opts[i], newState),
      ),
    );
  }
}
