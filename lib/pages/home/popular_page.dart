import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/sources/sources.dart';
import 'package:miru/data/structures/popular.dart';
import 'package:miru/main.dart';
import 'package:miru/pages/home/header_silver_builder.dart';
import 'package:miru/pages/home/home_list.dart';
import 'package:miru/pages/search_page.dart';

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
              popularFuture = Sources.get().getPopular();
              return;
            },
          );
        },
        color: isDark ? Colors.black : Colors.white,
        backgroundColor: isDark ? Colors.white : Colors.black,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool scroll) =>
              headerSilverBuilder(context, "Popular"),
          body: FutureBuilder(
            future: popularFuture,
            builder:
                (BuildContext context, AsyncSnapshot<List<Popular>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == null)
                return Center(
                  child: CupertinoActivityIndicator(),
                );

              return RefreshIndicator(
                onRefresh: () async {
                  setState(
                    () {
                      popularFuture = Sources.get().getPopular();
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
