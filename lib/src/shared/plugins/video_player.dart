import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

// For Windows video player
// import 'package:video_player_win/video_player_win.dart' ;

class VideoPlayerScreen extends StatelessWidget {
  final String url;

  const VideoPlayerScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.close),
          ),
          CustomVideoPlayer(url: url),
        ],
      ),
    );
  }
}

class CustomVideoPlayer extends StatefulWidget {
  final String url;

  const CustomVideoPlayer({super.key, required this.url});

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  bool isPlaying = false;
  bool _disposed = false;

  late VoidCallback _controllerListener;

  @override
  void initState() {
    super.initState();
    _initializePlayer(widget.url);
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _disposeControllers();
      _disposed = false;
      isPlaying = false;
      _chewieController = null;
      _initializePlayer(widget.url);
    }
  }

  void _initializePlayer(String url) {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (_disposed || !mounted) return;
        setState(() {});
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (_disposed || !mounted) return;
          _controller.play();
          isPlaying = true;
        });
      });

    _controllerListener = () {
      if (_disposed || !mounted) return;
      final value = _controller.value;
      if (!value.isInitialized) return;

      // Only rebuild once, to create the Chewie controller
      if (_chewieController == null) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _controller,
            autoPlay: true,
            looping: false,
            aspectRatio: value.aspectRatio,
            autoInitialize: true,
            errorBuilder: (context, errorMessage) {
              return Center(
                child: Text(errorMessage,
                    style: const TextStyle(color: Colors.white)),
              );
            },
          );
        });
      }

      // Only touch state when the video actually completes — not every tick
      if (value.isCompleted && isPlaying) {
        _controller.seekTo(Duration.zero);
        _controller.pause();
        setState(() => isPlaying =
            false); // no need to setState the whole tree every frame
      }
    };

    _controller.addListener(_controllerListener);
    _controller.setVolume(0);
  }

  void _disposeControllers() {
    _disposed = true;
    _controller.removeListener(_controllerListener);
    _chewieController?.dispose();
    _controller.dispose();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (_disposed || !mounted) return;
    if (info.visibleFraction > 0.5 && !isPlaying) {
      _controller.play();
      _chewieController?.play();
      isPlaying = true;
    } else if (info.visibleFraction <= 0.5 && isPlaying) {
      _controller.pause();
      _chewieController?.pause();
      isPlaying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key('video-key-${widget.url}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: _controller.value.isInitialized && _chewieController != null
          ? AspectRatio(
              aspectRatio: 16 / 9,
              child: Chewie(controller: _chewieController!),
            ) // Use Chewie for enhanced controls
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
