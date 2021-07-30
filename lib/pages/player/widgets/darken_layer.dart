import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
          Icon(CupertinoIcons.gobackward, color: Colors.white, size: 90)
        ])),
    // Right
    AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: Seek.darkenRight ? 1 : 0,
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Icon(CupertinoIcons.goforward, color: Colors.white, size: 90),
          Padding(padding: EdgeInsets.all(48))
        ])),
  ];
}
