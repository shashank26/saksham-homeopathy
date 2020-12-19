import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'constants.dart';

class CYoutubePlayer extends StatelessWidget {
  final String url;

  CYoutubePlayer(this.url);

  @override
  Widget build(BuildContext context) {
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: this.url,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
    return SafeArea(
      child: Material(
        color: Colors.black,
        child: Stack(children: [
          YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: false,
            progressIndicatorColor: AppColorPallete.color,
            onReady: () {
              _controller.addListener(() {});
            },
          ),
          Positioned(
              child: IconButton(
                icon: Icon(Icons.chevron_left),
                color: Colors.white,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              top: 5,
              left: 5)
        ]),
      ),
    );
  }
}
