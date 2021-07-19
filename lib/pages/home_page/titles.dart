import 'package:flutter/material.dart';

class Titles extends StatelessWidget {
  final String text;

  const Titles({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 4.0),
        child: Text(text,
            style: Theme.of(context)
                .textTheme
                .headline5!
                .copyWith(fontWeight: FontWeight.bold)));
  }
}
