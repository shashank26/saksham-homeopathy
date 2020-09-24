import 'dart:async';

import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/custom_dialog.dart';
import 'package:saksham_homeopathy/introduction/connecting.dart';
import 'package:video_player/video_player.dart';

class CVideoPlayer extends StatefulWidget {
  final VideoPlayerController _videoController;

  CVideoPlayer(this._videoController);
  @override
  _CVideoPlayerState createState() => _CVideoPlayerState();
}

class _CVideoPlayerState extends State<CVideoPlayer> {
  bool isInitialized = false;
  VideoPlayerValue _playerValue;
  bool _showOverlay = false;
  StreamSubscription _hideOverlay;

  getPlayerStateIcon() {
    if (_playerValue.isBuffering) {
      return CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
    }
    if (_playerValue.isPlaying) {
      return IconButton(
          icon: Icon(
            Icons.pause,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            setState(() {
              widget._videoController.pause();
            });
          });
    }
    if (!_playerValue.isPlaying) {
      return IconButton(
          icon: Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            if (_playerValue.position == _playerValue.duration) {
              widget._videoController.seekTo(Duration(seconds: 0));
            }
            widget._videoController.play();
          });
    }
  }

  getVisibilityState() {
    if (_playerValue.isBuffering) {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    // widget._videoController.initialize().then((value) {
    //   setState(() {
    //     isInitialized = true;
    //   });
    // });
  }

  _initVideoPlayer() {
    _playerValue = widget._videoController.value;
    widget._videoController.addListener(videoListener);
  }

  void videoListener() {
    setState(() {
      _playerValue = widget._videoController.value;
    });
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (!isInitialized) {
    //   return ConnectingPage();
    // }
    return SafeArea(
        child: Material(
      child: GestureDetector(
        onPanDown: (a) {
          setState(() {
            _showOverlay = true;
          });

          if (_hideOverlay != null) _hideOverlay.cancel();
        },
        onPanEnd: (a) {
          _hideOverlay =
              Future.delayed(Duration(seconds: 2)).asStream().listen((event) {
            setState(() {
              _showOverlay = false;
            });
          });
        },
        child: Container(
          color: Colors.black,
          child: Stack(children: [
            Center(
                child: AspectRatio(
                    aspectRatio: _playerValue.aspectRatio,
                    child: VideoPlayer(widget._videoController))),
            AnimatedOpacity(
              opacity: _showOverlay ? 1 : 0,
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 200),
              child: Container(
                  child: Stack(
                children: [
                  Center(child: getPlayerStateIcon()),
                  Positioned(
                      bottom: 50,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Slider(
                          activeColor: Colors.white,
                          inactiveColor: Colors.white.withOpacity(0.5),
                          value:
                              _playerValue.position.inMilliseconds.toDouble(),
                          min: 0,
                          max: _playerValue.duration.inMilliseconds.toDouble() +
                              10,
                          onChangeEnd: (value) {
                            setState(() {
                              widget._videoController.seekTo(
                                  Duration(milliseconds: value.toInt()));
                            });
                          },
                          onChanged: (value) {},
                        ),
                      )),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      widget._videoController.pause();
                      widget._videoController.removeListener(videoListener);
                      Navigator.pop(context);
                    },
                  ),
                ],
              )),
            ),
          ]),
        ),
      ),
    ));
  }
}
