import 'package:flutter/cupertino.dart';

void showInfo(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text("Info: Pinning/Marking"),
        content: Text(
            "Pinning shows and movies places them at the top of the home screen. "
            "Marking episodes records watch progress. "
            "Episodes will be automatically marked as you watch for your convenience."),
        actions: [
          CupertinoDialogAction(
            child: Text("Dismiss"),
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      );
    },
  );
}
