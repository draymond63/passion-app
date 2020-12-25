import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dart_random_choice/dart_random_choice.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:PassionFruit/helpers/globals.dart';
import 'package:PassionFruit/widgets/search/map.dart';
import 'package:PassionFruit/helpers/storage.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String focusedSite = '';

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<Storage>(context).items;
    // Scaffold required for search bar positioning
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.home),
        onPressed: () => focusSite(''),
      ),
      body: Stack(children: [
        FutureBuilder(
          future: loadMap(),
          builder: (context, AsyncSnapshot snap) {
            if (snap.hasData) {
              return Container(
                width: MediaQuery.of(context).size.width,
                child: Graph(snap.data, items, focusedSite),
              );
            }
            if (snap.hasError) return Text('${snap.error}');
            return LoadingWidget;
          },
        ),
        buildSearchBar(),
      ]),
    );
  }

  // * SEARCH BAR
  Widget buildSearchBar() {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      maxWidth: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: () => focusRandom(context),
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, anim) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.white,
          elevation: 4.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: Colors.accents.map((color) {
              return Container(height: 112, color: color);
            }).toList(),
          ),
        ),
      ),
    );
  }

  // Search Functions
  void focusRandom(BuildContext context) {
    final vitals = Provider.of<Map>(context, listen: false);
    focusSite(randomChoice(vitals.keys));
  }

  void focusSite(String site) => setState(() => focusedSite = site);
}
