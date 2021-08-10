import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:miru/data/persistent_data/data_storage.dart';
import 'package:miru/data/persistent_data/theme.dart';
import 'package:miru/data/sources/sources.dart';
import 'package:miru/main.dart';
import 'package:miru/pages/home/header_silver_builder.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    int server = Sources.getIndex();
    return Scaffold(
        body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool scroll) =>
                headerSilverBuilder(context, "Setings"),
            body: SingleChildScrollView(
                child: Column(children: [
              Container(
                  height: 60,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Theme", style: TextStyle(fontSize: 20)),
                            Expanded(child: Container()),
                            CupertinoSlidingSegmentedControl(
                                children: {
                                  ThemeMode.system: Text("System"),
                                  ThemeMode.light: Text("Light"),
                                  ThemeMode.dark: Text("Dark")
                                },
                                onValueChanged: (ThemeMode? mode) {
                                  AppTheme.setTheme(context, mode!);
                                  setState(() {});
                                },
                                groupValue: AppTheme.theme)
                          ]))),
              if (Theme.of(context).brightness == Brightness.dark)
                Divider(height: 0),
              if (Theme.of(context).brightness == Brightness.dark)
                InkWell(
                    onTap: () {
                      AppTheme.setFullBlack(context, !AppTheme.fullBlack);
                    },
                    child: Container(
                        height: 60,
                        child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text("Full Black",
                                      style: TextStyle(fontSize: 20)),
                                  Expanded(child: Container()),
                                  IgnorePointer(
                                      child: Switch(
                                          inactiveTrackColor:
                                              Colors.grey.withOpacity(0.6),
                                          value: AppTheme.fullBlack,
                                          onChanged: (a) {}))
                                ])))),
              Divider(height: 0),
              InkWell(
                  onTap: () async {
                    Color? color = await pickColor(
                        isDark, (AppTheme.color == null) ? "Cancel" : "Reset");
                    AppTheme.setColor(context, color);
                    setState(() {});
                  },
                  child: Container(
                      height: 60,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Accent Color",
                                    style: TextStyle(fontSize: 20)),
                                Expanded(child: Container()),
                                if (AppTheme.color != null)
                                  IconButton(
                                      onPressed: () {
                                        AppTheme.setColor(context, null);
                                      },
                                      icon: Icon(Icons.refresh),
                                      tooltip: "Reset Color"),
                                Padding(padding: EdgeInsets.all(4)),
                                ColorIndicator(
                                    color: AppTheme.color ??
                                        (isDark
                                            ? Colors.tealAccent
                                            : Colors.blueAccent))
                              ])))),
              Divider(height: 0),
              Container(
                  height: 60,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Server", style: TextStyle(fontSize: 20)),
                            Expanded(child: Container()),
                            DropdownButton(
                                underline: Container(
                                    color: AppTheme.color ??
                                        (isDark
                                            ? Colors.tealAccent
                                            : Colors.blueAccent),
                                    height: 2),
                                items: [
                                  DropdownMenuItem(
                                      child: Text("AnimeSuge"), value: 0),
                                  DropdownMenuItem(
                                      child: Text("GoGoAnime"), value: 1)
                                ],
                                value: server,
                                onChanged: (int? i) {
                                  if (server == i) return;
                                  setState(() {
                                    Sources.set(i!);
                                    server = i;
                                  });
                                  recentlyUpdatedFuture =
                                      Sources.get().getRecentReleases();
                                  popularFuture = Sources.get().getPopular();
                                })
                          ]))),
              Divider(height: 0),
              Container(height: 80),
              Divider(height: 0),
              InkWell(
                  onTap: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                              title: Text("Reset Watch Progress"),
                              content: Text(
                                  "This will reset all cached timestamps, including pinned shows and marked episodes!"),
                              actions: [
                                CupertinoActionSheetAction(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        Storage.clearAll();
                                      });
                                    },
                                    isDestructiveAction: true,
                                    child: Text("Reset")),
                                CupertinoActionSheetAction(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"))
                              ]);
                        });
                  },
                  child: Container(
                      height: 60,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Clear All Pinned",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.red))
                              ])))),
              Divider(height: 0),
              InkWell(
                  onTap: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return CupertinoAlertDialog(
                              title: Text("Reset All"),
                              content: Text(
                                  "This will reset all preferences and saved data!"),
                              actions: [
                                CupertinoActionSheetAction(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      setState(() {
                                        Storage.reset();
                                      });
                                    },
                                    isDestructiveAction: true,
                                    child: Text("Reset All")),
                                CupertinoActionSheetAction(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Cancel"))
                              ]);
                        });
                  },
                  child: Container(
                      height: 60,
                      child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text("Reset App Data",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.red))
                              ])))),
              Divider(height: 0)
            ]))));
  }

  Future<Color?> pickColor(bool isDark, String dismissText) async {
    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          Color color;
          if (AppTheme.color == null) {
            color = isDark ? Colors.tealAccent : Colors.blueAccent;
          } else
            color = AppTheme.color!;
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                ColorPicker(
                    enableShadesSelection: false,
                    pickersEnabled: {
                      ColorPickerType.both: false,
                      ColorPickerType.primary: false,
                      ColorPickerType.accent: true,
                      ColorPickerType.bw: false,
                      ColorPickerType.custom: false,
                      ColorPickerType.wheel: false
                    },
                    onColorChanged: (Color value) {
                      color = value;
                    }),
                CupertinoButton(
                    child: Text("Done",
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.black)),
                    onPressed: () {
                      Navigator.of(context).pop(color);
                    },
                    color: isDark ? Colors.white10 : Colors.black12),
                CupertinoButton(
                    child:
                        Text(dismissText, style: TextStyle(color: Colors.red)),
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    })
              ]));
        });
  }
}
