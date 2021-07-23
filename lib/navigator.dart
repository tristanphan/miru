import 'package:flutter/material.dart';
import 'package:miru/pages/library_page.dart';
import 'package:miru/pages/popular_page.dart';
import 'package:miru/pages/recently_updated_page.dart';
import 'package:miru/pages/settings.dart';

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
    SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).accentColor,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.feed), label: "Updated"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.leaderboard), label: "Popular"),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: "Library"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings), label: "Settings")
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
