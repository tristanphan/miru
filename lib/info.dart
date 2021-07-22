import 'package:flutter/cupertino.dart';

import 'data/data_storage.dart';

void showInfo(
    {required BuildContext context,
    required String url,
    required String name,
    required String image,
    required Function setState}) {
  bool pinned = isPinned(url);
  showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
            title: Text("Pinning"),
            content: Text(
                "Pinning shows and movies places them at the top of the home screen. "
                "Bookmarking episodes records watch progress. "
                "Episodes will be automatically bookmarked as you watch for your convenience. "),
            actions: [
              CupertinoDialogAction(
                  child: Text(pinned ? "Remove Pin" : "Add Pin"),
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (!pinned) {
                      addPin(url, name, image);
                      setState(() {});
                      return;
                    }
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
                                      removePin(url);
                                      Navigator.of(context).pop();
                                      setState(() {});
                                    }),
                                CupertinoDialogAction(
                                    child: Text("Cancel"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    })
                              ]);
                        });
                  }),
              CupertinoDialogAction(
                  child: Text("Dismiss"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  })
            ]);
      });
}
