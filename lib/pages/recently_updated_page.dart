import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/anime.dart';
import 'package:miru/data/structures/home.dart';
import 'package:miru/pages/search_page.dart';

import 'home_page/header_silver_builder.dart';
import 'home_page/homelist.dart';

Future<List<RecentRelease>> recentlyUpdatedFuture = Anime.getRecentReleases();

class RecentlyUpdatedPage extends StatefulWidget {
  const RecentlyUpdatedPage({Key? key}) : super(key: key);

  @override
  _RecentlyUpdatedPageState createState() => _RecentlyUpdatedPageState();
}

class _RecentlyUpdatedPageState extends State<RecentlyUpdatedPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (BuildContext context) => SearchPage()));
            },
            label: Text("Search"),
            icon: Icon(Icons.search)),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              recentlyUpdatedFuture = Anime.getRecentReleases();
              return;
            });
          },
          color: isDark ? Colors.black : Colors.white,
          backgroundColor: isDark ? Colors.white : Colors.black,
          child: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool scroll) =>
                  headerSilverBuilder(context, "Recently Updated"),
              body: FutureBuilder(
                  future: recentlyUpdatedFuture,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<RecentRelease>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.data == null)
                      return Center(child: CupertinoActivityIndicator());

                    return RefreshIndicator(
                        onRefresh: () async {
                          setState(() {
                            recentlyUpdatedFuture = Anime.getRecentReleases();
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
                                    subtext: (item) => item.latestEp,
                                    setState: setState))));
                  })),
        ));
  }
}
