import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/persistent_data/bookmark.dart';
import 'package:miru/data/persistent_data/data_storage.dart';
import 'package:miru/data/persistent_data/pin.dart';
import 'package:miru/data/structures/popular.dart';
import 'package:miru/pages/home/header_silver_builder.dart';
import 'package:miru/pages/home/home_list.dart';
import 'package:miru/pages/search_page.dart';
import 'package:palette_generator/palette_generator.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    Future<List<PaletteGenerator>> pinnedPalette = () async {
      return [
        for (Pin pin in Storage.pinned)
          await PaletteGenerator.fromImageProvider(
            NetworkImage(pin.image),
          ),
      ];
    }();
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => SearchPage(),
              ),
            ),
        label: Text("Search"),
        icon: Icon(Icons.search),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool scroll) =>
            headerSilverBuilder(context, "Library"),
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          color: isDark ? Colors.black : Colors.white,
          backgroundColor: isDark ? Colors.white : Colors.black,
          child: FutureBuilder(
            future: pinnedPalette,
            builder: (BuildContext context,
                AsyncSnapshot<List<PaletteGenerator>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == null)
                return Center(
                  child: CupertinoActivityIndicator(),
                );

              List<Popular> libraryItems = [];
              for (int index = Storage.pinned.length - 1; index >= 0; index--) {
                String latestEp = 'Not Started';

                for (Bookmark bookmark in Storage.pinned[index].episodes) {
                  if (bookmark.name.compareTo(latestEp) > 0 || latestEp == 'Not Started') latestEp = bookmark.name;
                }

                libraryItems.add(Popular(
                    image: Storage.pinned[index].image,
                    url: Storage.pinned[index].url,
                    title: Storage.pinned[index].title,
                    palette: snapshot.data![index],
                    subtext: '${Storage.pinned[index].source}\n$latestEp'));
              }

              if (libraryItems.isEmpty)
                return Center(
                  child: Text("Shows will appear here as you watch!"),
                );

              return Container(
                height: double.maxFinite,
                child: SingleChildScrollView(
                  child: HomeList(
                      list: libraryItems,
                      subtext: (item) => item.subtext,
                      setState: setState,
                      onReorder: (int oldIndex, int newIndex) {
                        setState(() {
                          oldIndex = Storage.pinned.length - oldIndex - 1;
                          newIndex = Storage.pinned.length - newIndex - 1;
                          Pin pin = Storage.pinned.removeAt(oldIndex);
                          Storage.pinned.insert(newIndex, pin);
                          Storage.save();
                        });
                      },
                      useCustomCrawler: true),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
