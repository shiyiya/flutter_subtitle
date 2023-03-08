## Getting started

- [x] webvtt suporrt
- [x] multiple line text
- [ ] extract html
- [ ] srt suporrt

![](https://i.ibb.co/BGcxskh/image.png)

```dart
import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_subtitle/flutter_subtitle.dart' hide Subtitle;
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const VideoApp());

class VideoApp extends StatefulWidget {
  const VideoApp({Key? key}) : super(key: key);

  @override
  State createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  ChewieController? _chewieController;
  late SubtitleController _subtitleController;

  @override
  void initState() {
    getWebVtt();
    super.initState();
  }

  getWebVtt() async {
    final body = (await http.get(Uri.parse(
            'https://cc.zorores.com/20/2e/202eaab6dff289a5976399077449654e/eng-2.vtt')))
        .body;

    _subtitleController = SubtitleController.string(body);
    final controller = VideoPlayerController.network(
        'https://vt1.doubanio.com/201902111139/0c06a85c600b915d8c9cbdbbaf06ba9f/view/movie/M/302420330.mp4');

    await controller.initialize();

    controller.addListener(() {
      setState(() {});
    });

    _chewieController = ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: true,
      subtitleBuilder: (context, subtitle) {
        return IgnorePointer(
          child: SubtitleView(
            text: subtitle,
            subtitleStyle: SubtitleStyle(
              fontSize: _chewieController!.isFullScreen ? 20 : 16,
            ),
          ),
        );
      },
    );

    //// Chewie Subtitle
    _chewieController!.setSubtitle(
      _subtitleController.subtitles
          .map(
            (e) => Subtitle(
              index: e.number,
              start: Duration(milliseconds: e.start),
              end: Duration(milliseconds: e.end),
              text: e.text,
            ),
          )
          .toList(),
    );

    //// Caption
    final webVTTCaptionFile = _subtitleController.subtitles
        .map((e) => Caption(
              number: e.number,
              start: Duration(milliseconds: e.start),
              end: Duration(milliseconds: e.end),
              text: e.text,
            ))
        .toList();

    controller.setClosedCaptionFile(
        Future.value(MyWebVTTCaptionFile(webVTTCaptionFile)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 200),
            _chewieController != null
                ? AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Chewie(controller: _chewieController!),
                  )
                : const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text('SubtitleControllView'),
            if (_chewieController != null)
              SubtitleControllView(
                subtitleController: _subtitleController,
                inMilliseconds: _chewieController!
                    .videoPlayerController.value.position.inMilliseconds,
                backgroundColor: Colors.yellow,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                subtitleStyle: const SubtitleStyle(
                  bordered: true,
                  borderStyle: SubtitleBorderStyle(
                    color: Colors.pink,
                    strokeWidth: 6,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text('ClosedCaption'),
            if (_chewieController != null)
              ClosedCaption(
                text:
                    _chewieController!.videoPlayerController.value.caption.text,
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _chewieController?.dispose();
  }
}

class MyWebVTTCaptionFile extends ClosedCaptionFile {
  MyWebVTTCaptionFile(this.captions);

  @override
  List<Caption> captions = [];
}
```
