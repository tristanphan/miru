import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/data_storage.dart';
import 'package:miru/data/structures/home.dart';
import 'package:palette_generator/palette_generator.dart';

import 'home_page/header_silver_builder.dart';
import 'home_page/homelist.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Future<List<PaletteGenerator>> pinnedPalette = () async {
      return [
        for (var image in pinnedImages)
          await PaletteGenerator.fromImageProvider(NetworkImage(image))
      ];
    }();
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                        title: Text("Reset Watch Progress"),
                        content: Text(
                            "This will reset all cached timestamps, including pinned shows and marked episodes!"),
                        actions: [
                          CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  clearAll();
                                });
                              },
                              isDestructiveAction: true,
                              child: Text("Reset All")),
                          CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Cancel"))
                        ]);
                  });
            },
            label: Text("Clear All"),
            icon: Icon(Icons.clear_all)),
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool scroll) =>
                headerSilverBuilder(context, "Library"),
            body: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: FutureBuilder(
                    future: pinnedPalette,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<PaletteGenerator>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.data == null)
                        return Center(child: CupertinoActivityIndicator());
                      List<Popular> libraryItems = [
                        for (int index = pinnedURLs.length - 1;
                            index >= 0;
                            index--)
                          Popular(
                              image: pinnedImages[index],
                              genres: "",
                              url: pinnedURLs[index],
                              title: pinnedNames[index],
                              latestEp: "",
                              palette: snapshot.data![index])
                      ];
                      if (libraryItems.isEmpty)
                        return Center(
                            child:
                                Text("Shows will appear here as you watch!"));

                      return Container(
                          height: double.maxFinite,
                          child: SingleChildScrollView(
                              child: HomeList(
                                  list: libraryItems,
                                  subtext: (item) => item.genres,
                                  setState: setState)));
                    }))));
  }
}
