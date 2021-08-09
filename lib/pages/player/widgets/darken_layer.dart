import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:miru/pages/player/functions/seek.dart';
import 'package:miru/pages/player/player_page.dart';

List<Widget> darkenLayer() {
  return [
    // Shows when Popup is shown
    AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: Player.showPopup
            ? 1
            : Seek.darkenLeft || Seek.darkenRight
                ? 0.5
                : 0,
        child: Container(color: Color.fromRGBO(0, 0, 0, 0.4))),

    // Seek Icons, shows on double tap only
    // Left
    AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: Seek.darkenLeft ? 1 : 0,
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Padding(padding: EdgeInsets.all(48)),
          Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fast_rewind, color: Colors.white, size: 90),
                Text("$seekAmount seconds")
              ])
        ])),
    // Right
    AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: Seek.darkenRight ? 1 : 0,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fast_forward, color: Colors.white, size: 90),
                Text("$seekAmount seconds")
              ]),
          Padding(padding: EdgeInsets.all(48))
        ]))
  ];
}
