import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/services/file_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:saksham_homeopathy/home/admin_updates/add_post.dart';

class FileView extends StatelessWidget {
  final File _file;
  final Function deletionCallback;
  FileView(this._file, this.deletionCallback);

  final supportedImages = ['.png', '.jpeg', '.jpg'];

  @override
  Widget build(BuildContext context) {
    if (this._file.path.endsWith('mp4')) {
      VideoPlayerController _controller =
          VideoPlayerController.file(this._file);
      return FutureBuilder(
          future: _controller.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container();
            }
            if (_controller.value.duration > Duration(minutes: 5)) {
              Future.delayed(Duration(seconds: 2)).then((value) {
                deletionCallback();
              });
              return Container(
                child: Text(
                  'Duration of video should be less than 5 minutes.',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }
            return Container(
              height: 150,
              width: _controller.value.aspectRatio * 150,
              child: Column(
                children: [
                  Material(
                    elevation: 10,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        children: [
                          VideoPlayer(_controller),
                          Container(
                            height: double.maxFinite,
                            width: double.maxFinite,
                            color: Colors.black.withOpacity(0.3),
                            child: IconButton(
                              icon: Icon(
                                context.watch<UploadStateTemp>().uploaded !=
                                        null
                                    ? Icons.file_upload
                                    : Icons.delete,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                if (context.read<UploadStateTemp>().uploaded !=
                                    null) {
                                  return;
                                }
                                FileHandler.instance.deleteRaw(this._file);
                                await this.deletionCallback();
                              },
                            ),
                          ),
                          Visibility(
                            visible:
                                context.watch<UploadStateTemp>().uploaded !=
                                    null,
                            child: Center(
                              child: Container(
                                  height: 40,
                                  width: 40,
                                  color: Colors.transparent,
                                  child: CircularProgressIndicator(
                                    backgroundColor: AppColorPallete.textColor,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColorPallete.backgroundColor),
                                    value: context
                                        .watch<UploadStateTemp>()
                                        .uploaded,
                                  )),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
    } else if (this
        .supportedImages
        .any((element) => this._file.path.endsWith(element))) {
      return Container(
        height: 150,
        width: 150,
        child: Material(
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Stack(
              children: [
                NetworkOrFileImage(
                  null,
                  null,
                  this._file.path,
                  raw: true,
                  height: 200,
                  width: 200,
                ),
                Container(
                  height: double.maxFinite,
                  width: double.maxFinite,
                  color: Colors.black.withOpacity(0.3),
                  child: IconButton(
                    icon: Icon(
                      context.watch<UploadStateTemp>().uploaded != null
                          ? Icons.file_upload
                          : Icons.delete,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (context.read<UploadStateTemp>().uploaded == null) {
                        FileHandler.instance.deleteRaw(this._file);
                        await this.deletionCallback();
                      }
                    },
                  ),
                ),
                Visibility(
                  visible: context.watch<UploadStateTemp>().uploaded != null,
                  child: Center(
                    child: Container(
                        height: 40,
                        width: 40,
                        color: Colors.transparent,
                        child: CircularProgressIndicator(
                          backgroundColor: AppColorPallete.textColor,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColorPallete.backgroundColor),
                          value: context.watch<UploadStateTemp>().uploaded,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container(
          height: 150,
          width: 150,
          child: Center(child: Text('This file is not supported')));
    }
  }
}
