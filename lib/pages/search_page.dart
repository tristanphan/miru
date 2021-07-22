import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:miru/data/anime.dart';
import 'package:miru/data/structures/search_item.dart';

import 'home_page/header_silver_builder.dart';
import 'home_page/homelist.dart';

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
              setState(() {
                items.clear();
              });
              items = await Anime.search(query, language);
              setState(() {});
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
                        setState(() {
                          items.clear();
                        });
                        items = await Anime.search(query, language);
                        FocusScope.of(context).requestFocus(FocusNode());
                        setState(() {});
                      })),
              Expanded(
                  child: items.length == 0
                      ? query.isEmpty
                          ? Container()
                          : Center(child: CupertinoActivityIndicator())
                      : SingleChildScrollView(
                          child: HomeList(
                              list: items,
                              subtext: (item) => item.released,
                              setState: setState)))
            ])));
  }
}
