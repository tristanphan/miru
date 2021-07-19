import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:miru/data/anime.dart';
import 'package:miru/data/data_storage.dart';
import 'package:miru/data/structures/home.dart';
import 'package:miru/pages/details_page.dart';
import 'package:miru/pages/home_page/titles.dart';
import 'package:miru/pages/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<Home>? home;

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    if (home == null) home = Anime.getHomePage();

    return Scaffold(
        appBar: AppBar(
            actions: [
              IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {
                      home = null;
                    });
                  })
            ],
            centerTitle: true,
            title: Text("Miru", style: TextStyle(fontWeight: FontWeight.bold))),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) {
                return SearchPage();
              }));
              setState(() {});
            },
            label: Text("Search"),
            icon: Icon(Icons.search)),
        body: FutureBuilder(
            future: home,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == null) {
                return Center(child: CupertinoActivityIndicator());
              }
              Home data = snapshot.data;
              return SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    if (pinnedNames.length != 0)
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Titles(text: "Pinned"),
                            IconButton(
                                icon: Icon(Icons.clear_all_rounded),
                                onPressed: () {
                                  showCupertinoModalPopup(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CupertinoActionSheet(
                                            actions: [
                                              CupertinoActionSheetAction(
                                                  child:
                                                      Text("Clear All Pinned"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    setState(() {
                                                      clearAll();
                                                    });
                                                  },
                                                  isDestructiveAction: true)
                                            ],
                                            cancelButton:
                                                CupertinoActionSheetAction(
                                                    child: Text("Cancel"),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    }));
                                      });
                                })
                          ]),
                    if (pinnedNames.length != 0)
                      Container(
                          height: 335,
                          child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              itemCount: pinnedNames.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: Card(
                                        elevation: 8,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            onTap: () async {
                                              await Navigator.of(context).push(
                                                  MaterialPageRoute(builder:
                                                      (BuildContext context) {
                                                return DetailsPage(
                                                    title: pinnedNames[index],
                                                    url: pinnedURLs[index]);
                                              }));
                                              setState(() {});
                                            },
                                            onLongPress: () async {
                                              showCupertinoModalPopup(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return CupertinoActionSheet(
                                                        actions: [
                                                          CupertinoActionSheetAction(
                                                              onPressed:
                                                                  () async {
                                                                await Navigator.of(
                                                                        context)
                                                                    .pushReplacement(MaterialPageRoute(builder:
                                                                        (BuildContext
                                                                            context) {
                                                                  return DetailsPage(
                                                                      title: pinnedNames[
                                                                          index],
                                                                      url: pinnedURLs[
                                                                          index]);
                                                                }));
                                                                setState(() {});
                                                              },
                                                              child:
                                                                  Text("Open")),
                                                          CupertinoActionSheetAction(
                                                              onPressed: () {
                                                                unpin(index);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  "Remove Pin"),
                                                              isDestructiveAction:
                                                                  true)
                                                        ],
                                                        cancelButton:
                                                            CupertinoActionSheetAction(
                                                                onPressed:
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop,
                                                                child: Text(
                                                                    "Cancel")));
                                                  });
                                            },
                                            child: Container(
                                                width: 200,
                                                padding: EdgeInsets.all(8),
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4)),
                                                      ClipRRect(
                                                          child: Image.network(
                                                              pinnedImages[
                                                                  index],
                                                              height: 220,
                                                              width:
                                                                  220 * 2 / 3,
                                                              fit: BoxFit.cover,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              loadingBuilder: (BuildContext
                                                                      context,
                                                                  Widget widget,
                                                                  ImageChunkEvent?
                                                                      progress) {
                                                            if (progress ==
                                                                null)
                                                              return widget;
                                                            return Container(
                                                                height: 220,
                                                                width:
                                                                    220 * 2 / 3,
                                                                child: Center(
                                                                    child:
                                                                        CupertinoActivityIndicator()));
                                                          }),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15)),
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4)),
                                                      Text(pinnedNames[index],
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(4))
                                                    ])))));
                              })),
                    Titles(text: "Recently Updated"),
                    Container(
                        height: 350,
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: data.recentReleases.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Card(
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          onTap: () async {
                                            await Navigator.of(context).push(
                                                MaterialPageRoute(builder:
                                                    (BuildContext context) {
                                              return DetailsPage(
                                                  title: data
                                                      .recentReleases[index]
                                                      .title,
                                                  url: data
                                                      .recentReleases[index]
                                                      .url);
                                            }));
                                            setState(() {});
                                          },
                                          child: Container(
                                              width: 200,
                                              padding: EdgeInsets.all(8),
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.all(4)),
                                                    ClipRRect(
                                                        child: Image.network(
                                                            data
                                                                .recentReleases[
                                                                    index]
                                                                .image,
                                                            height: 220,
                                                            width: 220 * 2 / 3,
                                                            fit: BoxFit.cover,
                                                            alignment: Alignment
                                                                .center,
                                                            loadingBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget
                                                                        widget,
                                                                    ImageChunkEvent?
                                                                        progress) {
                                                          if (progress == null)
                                                            return widget;
                                                          return Container(
                                                              height: 220,
                                                              width:
                                                                  220 * 2 / 3,
                                                              child: Center(
                                                                  child:
                                                                      CupertinoActivityIndicator()));
                                                        }),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15)),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.all(4)),
                                                    Text(
                                                        data
                                                                .recentReleases[
                                                                    index]
                                                                .title +
                                                            "\n",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.all(4)),
                                                    Text(data
                                                        .recentReleases[index]
                                                        .latestEp)
                                                  ])))));
                            })),
                    Titles(text: "Popular"),
                    Container(
                        height: 375,
                        child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: data.popular.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      elevation: 8,
                                      child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          onTap: () async {
                                            await Navigator.of(context).push(
                                                MaterialPageRoute(builder:
                                                    (BuildContext context) {
                                              return DetailsPage(
                                                  title:
                                                      data.popular[index].title,
                                                  url: data.popular[index].url);
                                            }));
                                            setState(() {});
                                          },
                                          child: Container(
                                              width: 200,
                                              padding: EdgeInsets.all(8),
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.all(4)),
                                                    ClipRRect(
                                                        child: Image.network(
                                                            data.popular[index]
                                                                .image,
                                                            height: 220,
                                                            width: 220 * 2 / 3,
                                                            fit: BoxFit.cover,
                                                            alignment: Alignment
                                                                .center,
                                                            loadingBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    Widget
                                                                        widget,
                                                                    ImageChunkEvent?
                                                                        progress) {
                                                          if (progress == null)
                                                            return widget;
                                                          return Container(
                                                              height: 220,
                                                              width:
                                                                  220 * 2 / 3,
                                                              child: Center(
                                                                  child:
                                                                      CupertinoActivityIndicator()));
                                                        }),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15)),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.all(4)),
                                                    Text(
                                                        data.popular[index]
                                                                .title +
                                                            "\n",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.all(4)),
                                                    Text(data.popular[index]
                                                        .latestEp),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.all(2)),
                                                    Text(
                                                        data.popular[index]
                                                            .genres,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis)
                                                  ])))));
                            })),
                    Padding(padding: EdgeInsets.all(8))
                  ]));
            }));
  }

  void unpin(int index) async {
    removePinAt(index);
    setState(() {});
  }
}
