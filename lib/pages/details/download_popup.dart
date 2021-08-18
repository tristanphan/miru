import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/structures/anime_details.dart';
import 'package:miru/pages/download_page.dart';

void downloadPopup(AnimeDetails details, int index, BuildContext context,
    void Function(VoidCallback fn) setState) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return Download(
                        name: details.name +
                            " (" +
                            details.episodes[index].name +
                            ")",
                        url: details.episodes[index].url);
                  },
                ),
              );
              setState(() {});
            },
            child: Text("Yes"),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
            },
            isDestructiveAction: true,
            child: Text("No"),
          ),
        ],
        content: Text(
            "Do you want to download " + details.episodes[index].name + "?"),
        title: Text("Download"),
      );
    },
  );
}
