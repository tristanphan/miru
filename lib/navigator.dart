import 'package:flutter/material.dart';
import 'package:miru/pages/library_page.dart';
import 'package:miru/pages/popular_page.dart';
import 'package:miru/pages/recently_updated_page.dart';
import 'package:miru/pages/search_page.dart';

class Navigation extends StatefulWidget {
  const Navigation({Key? key}) : super(key: key);

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int page = 0;
  List<Widget> pages = [
    RecentlyUpdatedPage(),
    PopularPage(),
    LibraryPage(),
    SearchPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.feed), label: "Updated"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.leaderboard), label: "Popular"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.leaderboard), label: "Library"),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search")
            ],
            currentIndex: page,
            onTap: (int index) {
              setState(() {
                page = index;
              });
            }),
        body: pages[page]);
  }
}
