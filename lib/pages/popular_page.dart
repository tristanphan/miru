import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/anime.dart';
import 'package:miru/data/structures/home.dart';

import 'home_page/header_silver_builder.dart';
import 'home_page/homelist.dart';

Future<List<Popular>> popularFuture = Anime.getPopular();

class PopularPage extends StatefulWidget {
  const PopularPage({Key? key}) : super(key: key);

  @override
  _PopularPageState createState() => _PopularPageState();
}

class _PopularPageState extends State<PopularPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              popularFuture = Anime.getPopular();
              return;
            });
          },
          color: isDark ? Colors.black : Colors.white,
          backgroundColor: isDark ? Colors.white : Colors.black,
          child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool scroll) =>
                  headerSilverBuilder(context, "Popular"),
              body: FutureBuilder(
                  future: popularFuture,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Popular>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.data == null)
                      return Center(child: CupertinoActivityIndicator());

                    return RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            popularFuture = Anime.getPopular();
                            return;
                          });
                        },
                        color: isDark ? Colors.black : Colors.white,
                        backgroundColor: isDark ? Colors.white : Colors.black,
                        child: Container(
                            height: double.maxFinite,
                            child: SingleChildScrollView(
                                child: HomeList(
                                    list: snapshot.data!,
                                    subtext: (item) => item.genres,
                                    setState: setState))));
                  })),
        ));
  }
}
