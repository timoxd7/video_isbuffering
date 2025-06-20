import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const VideoApp());

/// Stateful widget to fetch and then display video content.
class VideoApp extends StatefulWidget {
  const VideoApp({super.key});

  @override
  State<VideoApp> createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;

  bool buffering = false;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(
            Uri.parse(
              "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
            ),
          )
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
          });

    _controller.addListener(printBuffer);
  }

  void printBuffer() {
    print('----- BUFFERING: ${_controller.value.isBuffering}');

    setState(() {
      buffering = _controller.value.isBuffering;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: _controller.value.isInitialized
                  ? Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                        if (buffering)
                          Center(child: CircularProgressIndicator()),
                      ],
                    )
                  : const CircularProgressIndicator(),
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: <Widget>[
            // Skip to end button
            FloatingActionButton(
              onPressed: () async {
                final Duration end = _controller.value.duration;

                setState(() {
                  _controller.seekTo(end - const Duration(seconds: 5));
                });
              },
              child: const Icon(Icons.skip_next),
            ),

            // Skip 10s button
            FloatingActionButton(
              onPressed: () async {
                Duration? pos = await _controller.position;
                if (pos == null) {
                  return;
                }
                setState(() {
                  _controller.seekTo(pos + Duration(seconds: 10));
                });
              },
              child: Text('Skip 10s'),
            ),

            // Restart button
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.seekTo(Duration.zero);
                  _controller.play();
                });
              },
              child: const Icon(Icons.replay),
            ),

            // Play/Pause button
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
