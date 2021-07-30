import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:miru/data/anime.dart';
import 'package:miru/data/sources/sources.dart';
import 'package:miru/data/structures/search_item.dart';
import 'package:miru/pages/home/header_silver_builder.dart';
import 'package:miru/pages/home/home_list.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<SearchItem> items = [];
  Language language = Language.ALL;
  String query = "";
  FocusNode searchFocusNode = FocusNode();
  ScrollController _controller = ScrollController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    _controller.addListener(() {
      FocusScope.of(context).requestFocus(FocusNode());
    });
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              if (language == Language.ALL)
                language = Language.SUB;
              else if (language == Language.SUB)
                language = Language.DUB;
              else if (language == Language.DUB) language = Language.ALL;
              load(query);
            },
            label: Text(() {
              if (language == Language.ALL)
                return "All Languages";
              else if (language == Language.SUB)
                return "Subtitled Only";
              else
                return "Dubbed Only";
            }()),
            icon: Icon(Icons.translate)),
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool scroll) =>
                headerSilverBuilder(context, "Search"),
            body: Column(children: [
              Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: CupertinoSearchTextField(
                      focusNode: searchFocusNode,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black),
                      borderRadius: BorderRadius.circular(15),
                      onSubmitted: (String keyword) async {
                        query = keyword;
                        load(query);
                        FocusScope.of(context).requestFocus(FocusNode());
                      })),
              Expanded(
                  child: items.length == 0
                      ? loading
                          ? Center(child: CupertinoActivityIndicator())
                          : Center(
                              child: Text(query.isEmpty
                                  ? "Type something to begin"
                                  : "No results found"))
                      : SingleChildScrollView(
                          child: HomeList(
                              list: items,
                              subtext: (item) => item.subtitle,
                              setState: setState)))
            ])));
  }

  void load(String query) async {
    setState(() {
      loading = true;
      items.clear();
    });
    if (query.isNotEmpty) {
      items = await Sources.get().search(query, language);
    }
    setState(() {
      loading = false;
    });
  }
}
