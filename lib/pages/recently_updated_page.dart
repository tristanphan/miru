import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/anime.dart';
import 'package:miru/data/structures/home.dart';

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
    return Scaffold(
        body: NestedScrollView(
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
                      child: Container(
                          height: double.maxFinite,
                          child: SingleChildScrollView(
                              child: HomeList(
                                  list: snapshot.data!,
                                  subtext: (item) => item.latestEp,
                                  setState: setState))));
                })));
  }
}
