import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Native touch controls, with a full-width control bar on desktop.
class AppVideoControls extends StatelessWidget {
  const AppVideoControls({super.key});

  @override
  Widget build(BuildContext context) => switch (Theme.of(context).platform) {
    TargetPlatform.iOS => const CupertinoControls(
      backgroundColor: Color.fromRGBO(41, 41, 41, .7),
      iconColor: Color.fromARGB(255, 200, 200, 200),
    ),
    TargetPlatform.android ||
    TargetPlatform.fuchsia => const MaterialControls(),
    _ => const _DesktopVideoControls(),
  };
}

class _DesktopVideoControls extends StatefulWidget {
  const _DesktopVideoControls();

  @override
  State<_DesktopVideoControls> createState() => _DesktopVideoControlsState();
}

class _DesktopVideoControlsState extends State<_DesktopVideoControls> {
  ChewieController? _chewie;
  VideoPlayerController get _video => _chewie!.videoPlayerController;
  Timer? _hideTimer;
  bool _visible = true;
  bool _interacting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = ChewieController.of(context);
    if (identical(next, _chewie)) return;
    _chewie?.videoPlayerController.removeListener(_playbackChanged);
    _chewie = next;
    _video.addListener(_playbackChanged);
    _scheduleHide();
  }

  void _playbackChanged() {
    if (!_video.value.isPlaying) {
      _reveal();
    } else if (_hideTimer == null && _visible) {
      _scheduleHide();
    }
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = null;
    if (_interacting || !_video.value.isPlaying) return;
    _hideTimer = Timer(const Duration(seconds: 3), () {
      _hideTimer = null;
      if (mounted && _video.value.isPlaying && !_interacting) {
        setState(() => _visible = false);
      }
    });
  }

  void _reveal() {
    if (!_visible && mounted) setState(() => _visible = true);
    _scheduleHide();
  }

  void _holdControls() {
    _interacting = true;
    _reveal();
  }

  void _releaseControls() {
    _interacting = false;
    _reveal();
  }

  void _togglePlay() {
    _video.value.isPlaying ? _video.pause() : _video.play();
    _reveal();
  }

  void _seek(int seconds) {
    final value = _video.value;
    final target = (value.position.inMilliseconds + seconds * 1000).clamp(
      0,
      value.duration.inMilliseconds,
    );
    _video.seekTo(Duration(milliseconds: target));
    _reveal();
  }

  String _time(Duration time) {
    final minutes = time.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = time.inSeconds.remainder(60).toString().padLeft(2, '0');
    return time.inHours > 0
        ? '${time.inHours}:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _chewie?.videoPlayerController.removeListener(_playbackChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chewie = _chewie!;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.space): _togglePlay,
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _seek(10),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _seek(-10),
        const SingleActivator(LogicalKeyboardKey.keyF): () {
          if (chewie.allowFullScreen) chewie.toggleFullScreen();
        },
        const SingleActivator(LogicalKeyboardKey.escape): () {
          if (chewie.isFullScreen) chewie.exitFullScreen();
        },
      },
      child: Focus(
        autofocus: true,
        child: MouseRegion(
          cursor: !_visible && chewie.isFullScreen
              ? SystemMouseCursors.none
              : MouseCursor.defer,
          onHover: (_) => _reveal(),
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: _video,
            builder: (context, value, _) => value.hasError
                ? chewie.errorBuilder?.call(
                        context,
                        value.errorDescription ?? 'Unable to play video',
                      ) ??
                      const Center(
                        child: Text(
                          'Unable to play video',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _togglePlay,
                        onDoubleTap: chewie.allowFullScreen
                            ? chewie.toggleFullScreen
                            : null,
                      ),
                      if (value.isBuffering)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: IgnorePointer(
                          ignoring: !_visible,
                          child: AnimatedOpacity(
                            opacity: _visible ? 1 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black87],
                                ),
                              ),
                              child: SafeArea(
                                top: false,
                                bottom: chewie.isFullScreen,
                                minimum: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      child: MaterialVideoProgressBar(
                                        _video,
                                        barHeight: 3,
                                        handleHeight: 6,
                                        onDragStart: _holdControls,
                                        onDragEnd: _releaseControls,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        _button(
                                          value.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          value.isPlaying ? 'Pause' : 'Play',
                                          _togglePlay,
                                        ),
                                        if (chewie.allowMuting)
                                          _button(
                                            value.volume == 0
                                                ? Icons.volume_off
                                                : Icons.volume_up,
                                            value.volume == 0
                                                ? 'Unmute'
                                                : 'Mute',
                                            () {
                                              _video.setVolume(
                                                value.volume == 0 ? 1 : 0,
                                              );
                                              _reveal();
                                            },
                                          ),
                                        // Tight expansion consumes every spare pixel so the actions stay at the right edge.
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              '${_time(value.position)} / ${_time(value.duration)}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (chewie.showOptions)
                                          PopupMenuButton<double>(
                                            key: const ValueKey(
                                              'video-settings',
                                            ),
                                            tooltip: 'Playback speed',
                                            icon: const Icon(
                                              Icons.settings,
                                              color: Colors.white,
                                            ),
                                            initialValue: value.playbackSpeed,
                                            onOpened: _holdControls,
                                            onCanceled: _releaseControls,
                                            onSelected: (speed) {
                                              _video.setPlaybackSpeed(speed);
                                              _releaseControls();
                                            },
                                            itemBuilder: (_) => [
                                              for (final speed
                                                  in chewie.playbackSpeeds)
                                                PopupMenuItem(
                                                  value: speed,
                                                  child: Text('$speed×'),
                                                ),
                                            ],
                                          ),
                                        if (chewie.allowFullScreen)
                                          _button(
                                            chewie.isFullScreen
                                                ? Icons.fullscreen_exit
                                                : Icons.fullscreen,
                                            chewie.isFullScreen
                                                ? 'Exit fullscreen'
                                                : 'Fullscreen',
                                            chewie.toggleFullScreen,
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _button(IconData icon, String tooltip, VoidCallback onPressed) =>
      IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        style: IconButton.styleFrom(
          foregroundColor: Colors.white,
          minimumSize: const Size(40, 40),
        ),
      );
}
