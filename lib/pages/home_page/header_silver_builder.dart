import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

List<Widget> headerSilverBuilder(BuildContext context, String title,
    {Widget? trailing}) {
  return [
    CupertinoSliverNavigationBar(
        largeTitle: Text(title,
            maxLines: 1,
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black)),
        trailing: Material(
            color: Colors.transparent,
            child: trailing ??
                InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Icon(Icons.brightness_3),
                    onTap: () {
                      EasyDynamicTheme.of(context).changeTheme(
                          dark:
                              Theme.of(context).brightness == Brightness.light);
                    })))
  ];
}
