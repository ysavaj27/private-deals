import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/shared/plugins/video_controls.dart';
import 'package:private_deals/src/shared/theme/app_theme.dart';
import 'package:video_player/video_player.dart';

class _Video extends VideoPlayerController {
  _Video() : super.networkUrl(Uri.parse('https://example.com/pitch.mp4')) {
    value = value.copyWith(duration: const Duration(minutes: 2));
  }
  @override
  Future<void> play() async {
    value = value.copyWith(isPlaying: true);
  }

  @override
  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
  }

  @override
  Future<void> setVolume(double volume) async {
    value = value.copyWith(volume: volume);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) async {
    value = value.copyWith(playbackSpeed: speed);
  }

  @override
  Future<void> seekTo(Duration position) async {
    value = value.copyWith(position: position);
  }
}

void main() {
  testWidgets(
    'desktop settings and fullscreen stay at the right edge at every width',
    (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final width in [320.0, 700.0, 1200.0]) {
        final video = _Video();
        final chewie = ChewieController(
          videoPlayerController: video,
          customControls: const AppVideoControls(),
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.darkTheme.copyWith(platform: TargetPlatform.macOS),
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  key: const ValueKey('player'),
                  width: width,
                  height: width * 9 / 16,
                  child: Chewie(controller: chewie),
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 400));
        final player = tester.getRect(find.byKey(const ValueKey('player')));
        final fullscreen = tester.getRect(find.byIcon(Icons.fullscreen));
        final settings = tester.getRect(find.byIcon(Icons.settings));
        expect(player.right - fullscreen.right, lessThan(32));
        expect(player.bottom - fullscreen.bottom, lessThan(30));
        expect(settings.right, lessThanOrEqualTo(fullscreen.left));
        expect(fullscreen.left - settings.right, lessThan(40));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        chewie.dispose();
        await video.dispose();
      }
    },
  );

  testWidgets('play, mute, speed and fullscreen actions still work', (
    tester,
  ) async {
    final video = _Video();
    final chewie = ChewieController(
      videoPlayerController: video,
      customControls: const AppVideoControls(),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme.copyWith(platform: TargetPlatform.windows),
        home: Scaffold(
          body: AspectRatio(
            aspectRatio: 16 / 9,
            child: Chewie(controller: chewie),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byTooltip('Play'));
    await tester.pump();
    expect(video.value.isPlaying, isTrue);
    await tester.tap(find.byTooltip('Mute'));
    await tester.pump();
    expect(video.value.volume, 0);
    await tester.tap(find.byKey(const ValueKey('video-settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1.5×'));
    await tester.pumpAndSettle();
    expect(video.value.playbackSpeed, 1.5);
    await tester.tap(find.byTooltip('Fullscreen'));
    await tester.pumpAndSettle();
    expect(chewie.isFullScreen, isTrue);
    await tester.tap(find.byTooltip('Exit fullscreen'));
    await tester.pumpAndSettle();
    expect(chewie.isFullScreen, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    chewie.dispose();
    await video.dispose();
  });
}
