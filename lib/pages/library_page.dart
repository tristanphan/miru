import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/persistent_data/data_storage.dart';
import 'package:miru/data/persistent_data/pin.dart';
import 'package:miru/data/structures/popular.dart';
import 'package:miru/pages/home/header_silver_builder.dart';
import 'package:miru/pages/home/home_list.dart';
import 'package:palette_generator/palette_generator.dart';

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
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Future<List<PaletteGenerator>> pinnedPalette = () async {
      return [
        for (Pin pin in Storage.pinned)
          await PaletteGenerator.fromImageProvider(NetworkImage(pin.image))
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
                                  Storage.clearAll();
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
                color: isDark ? Colors.black : Colors.white,
                backgroundColor: isDark ? Colors.white : Colors.black,
                child: FutureBuilder(
                    future: pinnedPalette,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<PaletteGenerator>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.data == null)
                        return Center(child: CupertinoActivityIndicator());
                      List<Popular> libraryItems = [
                        for (int index = Storage.pinned.length - 1;
                            index >= 0;
                            index--)
                          Popular(
                              image: Storage.pinned[index].image,
                              url: Storage.pinned[index].url,
                              title: Storage.pinned[index].title,
                              palette: snapshot.data![index],
                              subtext: Storage.pinned[index].source)
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
                                  subtext: (item) => item.subtext,
                                  setState: setState)));
                    }))));
  }
}
