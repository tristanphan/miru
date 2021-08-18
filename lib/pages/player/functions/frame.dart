import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dart_vlc/dart_vlc.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

void saveFrame(BuildContext context, String videoUrl, Duration position) async {
  Directory temporary = (await getTemporaryDirectory());
  DateTime now = DateTime.now();
  String filename =
      'Screen Shot ${DateFormat('yyyy-MM-dd').format(now)} at ${DateFormat('h.mm.ss a').format(now)}.png';
  if (Platform.isIOS || Platform.isAndroid) {
    File file = File("${temporary.path}/$filename");
    Uint8List? bytes = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.PNG,
        maxHeight: 0,
        maxWidth: 0,
        quality: 100,
        timeMs: position.inMilliseconds);
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
              "Failed to save frame. This could happen if the video is of m3u8 format."),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      await file.writeAsBytes(bytes, flush: true);
      Share.shareFiles([file.path], subject: filename);
    }
  }
  if (Platform.isWindows || Platform.isLinux) {
    VideoFrame frame = await videoStreamControllers[1]!.stream.last;
    Completer<ui.Image> imageCompleter = new Completer<ui.Image>();
    ui.decodeImageFromPixels(
      frame.byteArray,
      frame.videoWidth,
      frame.videoHeight,
      ui.PixelFormat.bgra8888,
      (ui.Image _image) => imageCompleter.complete(_image),
      rowBytes: 4 * frame.videoWidth,
      targetWidth: frame.videoWidth,
      targetHeight: frame.videoHeight,
    );
    ui.Image image = await imageCompleter.future;

    File file = File("${temporary.path}/$filename");
    ByteData? bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Failed to save frame"),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);
      launch(file.uri.toString());
    }
  }
}
