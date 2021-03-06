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
    final map = Provider.of<List>(context);
    // Scaffold required for search bar positioning
    return Scaffold(
      body: Stack(children: [
        if (map.length == 0)
          LoadingWidget
        else
          Container(
            width: MediaQuery.of(context).size.width,
            child: Graph(map, items, focusedSite, _isSearching),
          ),
        buildSearchBar(),
      ]),
      // Only show home button if the user has
      floatingActionButton: (!_isSearching)
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Can't have 2 Floating Action Buttons wihtin the same widget
                RawMaterialButton(
                  child: Icon(
                    Icons.shuffle_rounded,
                    color: Theme.of(context).accentIconTheme.color,
                  ),
                  onPressed: focusRandom,
                  elevation: 2.0,
                  fillColor: Theme.of(context).accentColor,
                  padding: EdgeInsets.all(8.0),
                  shape: CircleBorder(),
                ),

                SizedBox(height: 24),
                if (items.length > 0)
                  FloatingActionButton(
                    child: Icon(Icons.star),
                    onPressed: () => focusSite(''),
                  ),
              ],
            )
          : null,
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
      actions: [FloatingSearchBarAction.searchToClear()],
      builder: (context, anim) => ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Material(
          color: Colors.white,
          elevation: 8.0,
          child: FutureBuilder(
              future: getSearchResults(),
              builder: (context, snap) {
                if (snap.hasData)
                  return Column(children: buildSearchItems(snap.data));
                else
                  return LoadingWidget;
              }),
        ),
      ),
    );
  }

  List<Widget> buildSearchItems(List<String> sites) {
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
  Future<List<String>> getSearchResults({maxAmount = 5}) async {
    final vitals = Provider.of<Map>(context);
    // Sanity checks
    if (vitals.length == 0 || _query.length == 0) return [];
    // Search algorithm
    final entries = vitals.entries.where(
      (entry) => entry.value['name'].toLowerCase().contains(_query),
    );
    // Convert to list of keys
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
