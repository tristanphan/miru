import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/sources/sources.dart';
import 'package:miru/data/structures/recent_release.dart';
import 'package:miru/main.dart';
import 'package:miru/pages/home/header_silver_builder.dart';
import 'package:miru/pages/home/home_list.dart';
import 'package:miru/pages/search_page.dart';

class RecentlyUpdatedPage extends StatefulWidget {
  const RecentlyUpdatedPage({Key? key}) : super(key: key);

  @override
  _RecentlyUpdatedPageState createState() => _RecentlyUpdatedPageState();
}

class _RecentlyUpdatedPageState extends State<RecentlyUpdatedPage> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => SearchPage(),
            ),
          );
        },
        label: Text("Search"),
        icon: Icon(Icons.search),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(
            () {
              recentlyUpdatedFuture = Sources.get().getRecentReleases();
              return;
            },
          );
        },
        color: isDark ? Colors.black : Colors.white,
        backgroundColor: isDark ? Colors.white : Colors.black,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool scroll) =>
              headerSilverBuilder(context, "Updated"),
          body: FutureBuilder(
            future: recentlyUpdatedFuture,
            builder: (BuildContext context,
                AsyncSnapshot<List<RecentRelease>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == null)
                return Center(
                  child: CupertinoActivityIndicator(),
                );

              return RefreshIndicator(
                onRefresh: () async {
                  setState(
                    () {
                      recentlyUpdatedFuture = Sources.get().getRecentReleases();
                      return;
                    },
                  );
                },
                color: isDark ? Colors.black : Colors.white,
                backgroundColor: isDark ? Colors.white : Colors.black,
                child: Container(
                  height: double.maxFinite,
                  child: SingleChildScrollView(
                    child: HomeList(
                        list: snapshot.data!,
                        subtext: (item) => item.subtext,
                        setState: setState),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
