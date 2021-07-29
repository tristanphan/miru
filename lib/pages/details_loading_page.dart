import 'package:flutter/material.dart';
import 'package:miru/data/sources/sources.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/pages/details_page.dart';
import 'package:miru/pages/home/home_card.dart';

class DetailsLoadingPage extends StatefulWidget {
  final String title;
  final String url;
  final HomeCard homeCard;

  const DetailsLoadingPage(
      {Key? key,
      required this.title,
      required this.url,
      required this.homeCard})
      : super(key: key);

  @override
  _DetailsLoadingPageState createState() => _DetailsLoadingPageState();
}

class _DetailsLoadingPageState extends State<DetailsLoadingPage> {
  Future<AnimeDetails>? detailsFuture;
  bool popped = false;

  @override
  void initState() {
    super.initState();
    Sources.get().getDetails(widget.url).then((details) {
      if (!mounted || popped) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => DetailsPage2(
              details: details,
              url: widget.url,
              title: widget.title,
              homeCard: widget.homeCard)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(alignment: Alignment.center, children: [
      Positioned(
          top: 40,
          left: 20,
          child: FloatingActionButton.extended(
              heroTag: "back",
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              onPressed: () {
                popped = true;
                Navigator.of(context).pop();
              },
              label: Text("Back"),
              icon: Icon(Icons.navigate_before_rounded))),
      Center(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            widget.homeCard,
            Padding(padding: EdgeInsets.all(4)),
            Text("Loading...",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
          ]))
    ]));
  }
}
