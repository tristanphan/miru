import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/pages/home_page/homecard.dart';

class HomeList extends StatefulWidget {
  final List<dynamic> list;
  final String Function(dynamic item) subtext;
  final Function(VoidCallback fn) setState;

  const HomeList(
      {Key? key,
      required this.list,
      required this.subtext,
      required this.setState})
      : super(key: key);

  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  @override
  Widget build(BuildContext context) {
    double idealWidth = 350;
    double deviceWidth = MediaQuery.of(context).size.width - 16;
    double width = min(deviceWidth / (deviceWidth ~/ idealWidth), deviceWidth);

    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
            alignment: WrapAlignment.center,
            direction: Axis.horizontal,
            children: [
              for (var item in widget.list)
                HomeCard(
                    title: item.title,
                    img: item.image,
                    subtext: widget.subtext(item),
                    palette: item.palette,
                    width: width,
                    url: item.url,
                    setState: widget.setState)
            ]));
  }
}
