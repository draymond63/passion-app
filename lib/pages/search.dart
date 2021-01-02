import 'package:PassionFruit/widgets/bookshelf/itemPreview.dart';
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
  final _searcher = FloatingSearchBarController();
  bool _isSearching = false;
  String _query = '';
  String focusedSite = '';

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<Storage>(context).items;
    // Scaffold required for search bar positioning
    return Scaffold(
      // Only show home button if the user has
      floatingActionButton: items.length > 0
          ? FloatingActionButton(
              child: Icon(Icons.home),
              onPressed: () => focusSite(''),
            )
          : null,
      body: Stack(children: [
        FutureBuilder(
          future: loadMap(),
          builder: (context, AsyncSnapshot snap) {
            if (snap.hasData) {
              return Container(
                width: MediaQuery.of(context).size.width,
                child: Graph(snap.data, items, focusedSite, _isSearching),
              );
            }
            if (snap.hasError) return Center(child: Text('${snap.error}'));
            return LoadingWidget;
          },
        ),
        buildSearchBar(),
      ]),
    );
  }

  // * SEARCH BAR
  Widget buildSearchBar() {
    return FloatingSearchBar(
      hint: 'Search...',
      controller: _searcher,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      debounceDelay: const Duration(milliseconds: 500),
      transition: CircularFloatingSearchBarTransition(),
      onFocusChanged: (status) => setState(() => _isSearching = status),
      onQueryChanged: (query) => setState(() => _query = query.toLowerCase()),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.shuffle_rounded),
            onPressed: () => focusRandom(),
          ),
        ),
        FloatingSearchBarAction.searchToClear(showIfClosed: false),
      ],
      builder: (context, anim) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.white,
          elevation: 8.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: buildSearchItems(),
          ),
        ),
      ),
    );
  }

  List<Widget> buildSearchItems() {
    final vitals = Provider.of<Map>(context);
    if (vitals.length == 0) return [];
    final sites = _query.length > 0 ? getSearchResults(vitals) : [];

    return List<PreviewItem>.generate(
      sites.length,
      (i) => PreviewItem(
        sites[i],
        width: MediaQuery.of(context).size.width,
        onClick: () => clickSearchItem(sites[i]),
      ),
    );
  }

  // * Search Functions
  // ! MAKE ASYNC
  List<String> getSearchResults(Map vitals, {maxAmount = 5}) {
    final entries = vitals.entries.where(
      (entry) => entry.value['name'].toLowerCase().contains(_query),
    );
    final results = entries.map((entry) => entry.key).toList().cast<String>();
    if (results.length > maxAmount)
      return results.getRange(0, maxAmount).toList();
    else
      return results;
  }

  clickSearchItem(String site) {
    focusSite(site);
    _searcher.close();
  }

  void focusRandom() {
    final vitals = Provider.of<Map>(context, listen: false);
    focusSite(randomChoice(vitals.keys));
  }

  // Updating focusedSite causes Graph to reposition
  void focusSite(String site) => setState(() => focusedSite = site);
}
