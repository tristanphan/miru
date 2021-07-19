import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:miru/data/anime.dart';
import 'package:miru/data/structures/search_item.dart';

import 'details_page.dart';

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
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: Text("Search")),
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
        body: Column(children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                  focusNode: searchFocusNode,
                  style: TextStyle(color: Colors.white),
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
                  : ListView.separated(
                      controller: _controller,
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return DetailsPage(
                                    title: items[index].title,
                                    url: items[index].url);
                              }));
                            },
                            child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 16.0),
                                child: Row(children: [
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(items[index].image,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.center,
                                          width: 200 * 2 / 3,
                                          height: 200, loadingBuilder:
                                              (BuildContext context,
                                                  Widget widget,
                                                  ImageChunkEvent? progress) {
                                        if (progress == null) return widget;
                                        return Container(
                                            width: 200 * 2 / 3,
                                            height: 200,
                                            child: Center(
                                                child:
                                                    CupertinoActivityIndicator()));
                                      })),
                                  Padding(padding: EdgeInsets.all(8)),
                                  Expanded(
                                      child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                        Text(items[index].title,
                                            style: TextStyle(fontSize: 22),
                                            softWrap: true,
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis),
                                        if (items[index].released.isNotEmpty)
                                          Text("Released: " +
                                              items[index].released)
                                      ])),
                                  Icon(Icons.navigate_next)
                                ])));
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(height: 0);
                      }))
        ]));
  }
}
