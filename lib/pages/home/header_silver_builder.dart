import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

List<Widget> headerSilverBuilder(BuildContext context, String title,
    {Widget? trailing}) {
  return [
    CupertinoSliverNavigationBar(
        backgroundColor:
            (Theme.of(context).scaffoldBackgroundColor == Colors.black)
                ? Colors.black
                : CupertinoTheme.of(context).barBackgroundColor,
        largeTitle: Text(title,
            maxLines: 1,
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black)))
  ];
}
