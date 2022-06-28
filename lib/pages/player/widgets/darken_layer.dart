import 'package:flutter/material.dart';
import 'package:miru/pages/player/functions/seek.dart';
import 'package:miru/pages/player/player_page.dart';

List<Widget> darkenLayer() {
  return [
    // Shows when Popup is shown
    AnimatedOpacity(
      duration: Duration(milliseconds: 200),
      opacity: Player.showPopup ? 1 : 0,
      child: Container(
        color: Color.fromRGBO(0, 0, 0, 0.4),
      ),
    ),

    // Left seek
    AnimatedOpacity(
      duration: Duration(milliseconds: 200),
      opacity: Seek.left ? 1 : 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromRGBO(0, 0, 0, 0.4),
            Color.fromRGBO(0, 0, 0, 0),
          ], begin: Alignment.centerLeft, end: Alignment.centerRight),
        ),
      ),
    ),

    // Right seek
    AnimatedOpacity(
      duration: Duration(milliseconds: 200),
      opacity: Seek.right ? 1 : 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Color.fromRGBO(0, 0, 0, 0.4),
            Color.fromRGBO(0, 0, 0, 0),
          ], begin: Alignment.centerRight, end: Alignment.centerLeft),
        ),
      ),
    ),

    // Seek Icons, shows on double tap only
    // Left
    AnimatedOpacity(
      duration: Duration(milliseconds: 200),
      opacity: Seek.left ? 1 : 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(48),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fast_rewind, color: Colors.white, size: 90),
              Text("$seekAmount seconds"),
            ],
          ),
        ],
      ),
    ),
    // Right
    AnimatedOpacity(
      duration: Duration(milliseconds: 200),
      opacity: Seek.right ? 1 : 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fast_forward, color: Colors.white, size: 90),
              Text("$seekAmount seconds"),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(48),
          ),
        ],
      ),
    ),
  ];
}
