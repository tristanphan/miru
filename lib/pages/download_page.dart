import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:miru/data/sources/sources.dart';
import 'package:miru/data/structures/video_details.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

class Download extends StatefulWidget {
  final String name;
  final String url;

  const Download({Key? key, required this.name, required this.url})
      : super(key: key);

  @override
  _DownloadState createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  int received = 0;
  int total = 100;
  String progress = "Downloading...";
  CancelToken cancelToken = CancelToken();
  bool canCancel = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    download();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Theme(
        data: ThemeData.dark(),
        child: Scaffold(
          appBar: AppBar(
            leading: Container(),
            centerTitle: true,
            title: Text(widget.name),
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  progress,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                ),
                Container(
                  width: 300,
                  child: FAProgressBar(
                      borderRadius: BorderRadius.circular(15),
                      animatedDuration: Duration(milliseconds: 300),
                      maxValue: total.toDouble(),
                      size: 10,
                      backgroundColor: Colors.white24,
                      progressColor: Colors.white,
                      currentValue: received.toDouble()),
                ),
                Padding(
                  padding: EdgeInsets.all(4),
                ),
                Text(
                  ((received / total * 10000).floor() ~/ 100).toString() + "%",
                  style: TextStyle(fontSize: 16),
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                ),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: canCancel ? 1 : 0,
                  child: CupertinoButton(
                      onPressed: canCancel
                          ? () {
                              cancelToken.cancel();
                              Navigator.of(context).pop();
                            }
                          : null,
                      child: Text(hasError ? "Close" : "Cancel"),
                      color: hasError ? Colors.red : Colors.white12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void download() async {
    setState(
      () => progress = "Getting Video Path",
    );
    String videoPath =
        (await getTemporaryDirectory()).path + "/" + widget.name + ".mp4";
    VideoDetails? video = await Sources.get().getVideo(
      widget.url,
      (a, b) {},
    );
    canCancel = true;
    if (video == null) {
      onError();
      return;
    }
    setState(
      () => progress = "Downloading Video",
    );
    bool hasError = false;
    await Dio()
        .download(
      video.url,
      videoPath,
      cancelToken: cancelToken,
      onReceiveProgress: (int r, int t) => setState(
        () {
          received = r;
          total = t;
        },
      ),
    )
        .catchError(
      (error, stackTrace) {
        error = true;
        onError();
      },
    );
    if (cancelToken.isCancelled || hasError) return;
    await Share.shareFiles(
      [videoPath],
    );
    Navigator.of(context).pop();
  }

  void onError() {
    setState(
      () {
        hasError = true;
        progress = "Error!";
      },
    );
  }
}
