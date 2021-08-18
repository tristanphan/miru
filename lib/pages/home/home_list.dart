import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/pages/home/home_card.dart';
import 'package:reorderables/reorderables.dart';

class HomeList extends StatefulWidget {
  final List<dynamic> list;
  final String Function(dynamic item) subtext;
  final Function(VoidCallback fn) setState;
  final bool? useCustomCrawler;
  final void Function(int oldIndex, int newIndex)? onReorder;

  const HomeList(
      {Key? key,
      required this.list,
      required this.subtext,
      required this.setState,
      this.useCustomCrawler,
      this.onReorder})
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

    List<Widget> wrap = [
      for (dynamic item in widget.list)
        HomeCard(
            title: item.title,
            img: item.image,
            subtext: widget.subtext(item),
            palette: item.palette,
            width: width,
            url: item.url,
            setState: widget.setState,
            useCustomCrawler: widget.useCustomCrawler),
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: widget.onReorder != null
          ? ReorderableWrap(
              alignment: WrapAlignment.center,
              direction: Axis.horizontal,
              onReorder: widget.onReorder!,
              needsLongPressDraggable: false,
              children: wrap,
              buildDraggableFeedback: (BuildContext context,
                  BoxConstraints constraints, Widget widget) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: constraints.maxWidth - 16,
                      height: constraints.maxHeight - 16,
                    ),
                    widget
                  ],
                );
              },
            )
          : Wrap(
              alignment: WrapAlignment.center,
              direction: Axis.horizontal,
              children: wrap,
            ),
    );
  }
}
