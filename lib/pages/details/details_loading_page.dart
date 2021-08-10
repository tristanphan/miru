import 'package:flutter/material.dart';
import 'package:miru/data/sources/sources.dart';
import 'package:miru/pages/details/details_page.dart';
import 'package:miru/pages/home/home_card.dart';

class DetailsLoadingPage extends StatefulWidget {
  final String title;
  final String url;
  final HomeCard homeCard;
  final bool? useCustomCrawler;

  const DetailsLoadingPage(
      {Key? key,
      required this.title,
      required this.url,
      required this.homeCard,
      this.useCustomCrawler})
      : super(key: key);

  @override
  _DetailsLoadingPageState createState() => _DetailsLoadingPageState();
}

class _DetailsLoadingPageState extends State<DetailsLoadingPage> {
  bool popped = false;

  @override
  void initState() {
    super.initState();
    Sources.get(
            (widget.useCustomCrawler ?? false) ? widget.homeCard.subtext : null)
        .getDetails(widget.url)
        .then((details) {
      if (!mounted || popped) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => DetailsPage(
              details: details,
              url: widget.url,
              title: widget.title,
              useCustomCrawler: widget.useCustomCrawler,
              homeCard: widget.homeCard)));
    }, onError: (obj, stackTrace) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(alignment: Alignment.center, children: [
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
