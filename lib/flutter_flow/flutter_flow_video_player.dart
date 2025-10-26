// TODO: Install chewie package for full video player functionality
// import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart' show routeObserver;

const kDefaultAspectRatio = 16 / 9;

enum VideoType {
  asset,
  network,
}

Set<VideoPlayerController> _videoPlayers = Set();

// Simplified video player without Chewie (install chewie package for full controls)
class FlutterFlowVideoPlayer extends StatefulWidget {
  const FlutterFlowVideoPlayer({
    super.key,
    required this.path,
    this.videoType = VideoType.network,
    this.width,
    this.height,
    this.aspectRatio,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
    this.allowFullScreen = true,
    this.allowPlaybackSpeedMenu = false,
    this.lazyLoad = false,
    this.pauseOnNavigate = true,
  });

  final String path;
  final VideoType videoType;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final bool allowFullScreen;
  final bool allowPlaybackSpeedMenu;
  final bool lazyLoad;
  final bool pauseOnNavigate;

  @override
  State<StatefulWidget> createState() => _FlutterFlowVideoPlayerState();
}

class _FlutterFlowVideoPlayerState extends State<FlutterFlowVideoPlayer>
    with RouteAware {
  VideoPlayerController? _videoPlayerController;
  bool _loggedError = false;
  bool _subscribedRoute = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    if (_subscribedRoute) {
      routeObserver.unsubscribe(this);
    }
    _disposeCurrentPlayer();
    super.dispose();
  }

  @override
  void didUpdateWidget(FlutterFlowVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _disposeCurrentPlayer();
      _initializePlayer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.pauseOnNavigate && ModalRoute.of(context) is PageRoute) {
      _subscribedRoute = true;
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    }
  }

  @override
  void didPushNext() {
    if (widget.pauseOnNavigate) {
      _videoPlayerController?.pause();
    }
  }

  double get width => widget.width == null || widget.width! >= double.infinity
      ? MediaQuery.sizeOf(context).width
      : widget.width!;

  double get height =>
      widget.height == null || widget.height! >= double.infinity
          ? width / aspectRatio
          : widget.height!;

  double get aspectRatio =>
      _videoPlayerController?.value.aspectRatio ??
      widget.aspectRatio ??
      kDefaultAspectRatio;

  void _disposeCurrentPlayer() {
    _videoPlayers.remove(_videoPlayerController);
    _videoPlayerController?.dispose();
  }

  Future _initializePlayer() async {
    _videoPlayerController = widget.videoType == VideoType.network
        ? VideoPlayerController.networkUrl(Uri.parse(widget.path))
        : VideoPlayerController.asset(widget.path);
    if (kIsWeb && widget.autoPlay) {
      _videoPlayerController!.setVolume(0);
    }
    if (!widget.lazyLoad) {
      await _videoPlayerController?.initialize();
    }

    _videoPlayerController!.setLooping(widget.looping);
    if (widget.autoPlay) {
      _videoPlayerController!.play();
    }

    _videoPlayers.add(_videoPlayerController!);
    _videoPlayerController!.addListener(() {
      if (_videoPlayerController!.value.hasError && !_loggedError) {
        print(
            'Error playing video: ${_videoPlayerController!.value.errorDescription}');
        _loggedError = true;
      }
      if (_videoPlayerController!.value.isPlaying) {
        _videoPlayers.forEach((otherPlayer) {
          if (otherPlayer != _videoPlayerController &&
              otherPlayer.value.isPlaying &&
              mounted) {
            setState(() {
              otherPlayer.pause();
            });
          }
        });
      }
    });

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => FittedBox(
        fit: BoxFit.cover,
        child: Container(
          height: height,
          width: width,
          child: _videoPlayerController != null &&
                  (widget.lazyLoad ||
                      _videoPlayerController!.value.isInitialized)
              ? AspectRatio(
                  aspectRatio: aspectRatio,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      VideoPlayer(_videoPlayerController!),
                      if (widget.showControls)
                        VideoProgressIndicator(_videoPlayerController!,
                            allowScrubbing: true),
                      if (widget.showControls)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: IconButton(
                            icon: Icon(
                              _videoPlayerController!.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _videoPlayerController!.value.isPlaying
                                    ? _videoPlayerController!.pause()
                                    : _videoPlayerController!.play();
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                )
              : (_videoPlayerController != null &&
                      _videoPlayerController!.value.hasError)
                  ? Text('Error playing video')
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text('Loading'),
                      ],
                    ),
        ),
      );
}
