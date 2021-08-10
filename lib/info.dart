import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/persistent_data/data_storage.dart';
import 'package:miru/navigator.dart';

Future<void> showInfo(
    {required BuildContext context,
    required String url,
    required String name,
    required String image,
    required Function setState,
    required bool pop}) async {
  bool pinned = Storage.isPinned(url);
  Completer finish = Completer();
  await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
            title: Text("Pinning"),
            content: Text(
                "Pinned shows and movies appear in the Library page. "
                "Your watching progress is saved automatically and is cleared when you unpin the show."),
            actions: [
              CupertinoDialogAction(
                  child: Text(pinned ? "Remove Pin" : "Add Pin"),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (!pinned) {
                      Storage.addPin(url, name, image);
                      setState(() {});
                      finish.complete();
                    } else {
                      showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                                title: Text("Remove Pin"),
                                content: Text(
                                    "All your viewing progress in this show will be cleared!"),
                                actions: [
                                  CupertinoDialogAction(
                                      child: Text("Remove"),
                                      isDestructiveAction: true,
                                      onPressed: () {
                                        Storage.removePin(url);
                                        if (!pop) {
                                          Navigator.of(context).pop();
                                        } else {
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          Navigation()),
                                                  (route) => false);
                                        }
                                        finish.complete();
                                      }),
                                  CupertinoDialogAction(
                                      child: Text("Cancel"),
                                      onPressed: () {
                                        finish.complete();
                                        Navigator.of(context).pop();
                                      })
                                ]);
                          });
                    }
                  }),
              CupertinoDialogAction(
                  child: Text("Dismiss"),
                  onPressed: () {
                    finish.complete();
                    Navigator.of(context).pop();
                  })
            ]);
      });
  await finish.future;
}
