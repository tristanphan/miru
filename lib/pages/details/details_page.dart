import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/persistent_data/data_storage.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/info.dart';
import 'package:miru/pages/details/details_card.dart';
import 'package:miru/pages/details/details_loading_page.dart';
import 'package:miru/pages/details/episode_card.dart';
import 'package:miru/pages/home/header_silver_builder.dart';
import 'package:miru/pages/home/home_card.dart';
import 'package:palette_generator/palette_generator.dart';

class DetailsPage extends StatefulWidget {
  final AnimeDetails details;
  final String title;
  final String url;
  final HomeCard homeCard;

  const DetailsPage(
      {Key? key,
      required this.details,
      required this.title,
      required this.url,
      required this.homeCard})
      : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    AnimeDetails details = widget.details;
    bool pinned = Storage.isPinned(widget.url);
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color cardColor;
    PaletteColor? cardSet = isDark
        ? details.palette.vibrantColor
        : details.palette.lightVibrantColor;
    if (cardSet == null) {
      cardColor = isDark ? Colors.blueGrey : Colors.lightBlueAccent.shade100;
    } else {
      cardColor = cardSet.color;
    }
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showInfo(
                  context: context,
                  url: widget.url,
                  name: widget.title,
                  image: details.image,
                  setState: setState);
            },
            label: Text(pinned ? "Unpin" : "Pin"),
            icon: Icon(pinned ? Icons.favorite : Icons.favorite_border),
            foregroundColor: pinned
                ? Colors.white
                : isDark
                    ? Colors.black
                    : Colors.white,
            backgroundColor: pinned
                ? Colors.red
                : isDark
                    ? Colors.white
                    : Colors.black),
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool scroll) =>
                headerSilverBuilder(
                    context, widget.title.replaceAll(' (Dub)', '')),
            body: Container(
                height: double.maxFinite,
                child: RefreshIndicator(
                    color: isDark ? Colors.black : Colors.white,
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    onRefresh: () async {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) => DetailsLoadingPage(
                              homeCard: widget.homeCard,
                              title: widget.title,
                              url: widget.url)));
                    },
                    child: Scrollbar(
                        child: SingleChildScrollView(
                            child: Column(children: [
                      detailsCard(
                          context, details, cardColor, isDark, setState),
                      Padding(padding: EdgeInsets.all(4)),
                      Divider(height: 0),
                      MediaQuery.removePadding(
                          removeTop: true,
                          context: context,
                          child: ListView.separated(
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: details.episodes.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) => episodeCard(
                                  context,
                                  details,
                                  index,
                                  pinned,
                                  isDark,
                                  setState),
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      Divider(height: 0)))
                    ])))))));
  }
}
