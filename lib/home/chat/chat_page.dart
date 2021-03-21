import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:saksham_homeopathy/common/CTextFormField.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/image_modal_nottom_sheet_dialog.dart';
import 'package:saksham_homeopathy/common/image_source_bottom_sheet.dart';
import 'package:saksham_homeopathy/common/message_bubble.dart';
import 'package:saksham_homeopathy/home/history/historyPage.dart';
import 'package:saksham_homeopathy/home/profile/preview_profile.dart';
import 'package:saksham_homeopathy/home/profile/profile_avatar.dart';
import 'package:saksham_homeopathy/models/message_info.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/chat_service.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ChatPage extends StatefulWidget {
  final ChatService chatService;
  final bool whitelisted;
  final ProfileInfo _profileInfo;
  final Stream<bool> _isVisibleStream;
  ChatPage(this.chatService, this._profileInfo, this._isVisibleStream,
      {this.whitelisted = false});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController(text: '');
  bool _imageSendingInProcess = false;
  bool _isNewChat = true;
  AutoScrollController controller;
  List<DocumentSnapshot> messages = [];
  bool oldMessagesLoadingFlag = false;
  Stream<QuerySnapshot> chatStream;
  int batch = 1;
  final int batchSize = 20;
  StreamSubscription ss, vis, unread;
  bool shouldScroll = false;
  int messageSent = 0;
  String nonWhitlistMessage =
      'This is a trial period you can send 10 messages to the doctor.';

  @override
  initState() {
    super.initState();
    if (vis == null && widget._isVisibleStream != null) {
      unread = ChatService.unreadMessageStream();
      vis = widget._isVisibleStream.listen((event) {
        bool isRunning() => ss != null && !ss.isPaused;
        if (event) {
          if (ss == null) {
            initChatStream();
            Future.delayed(Duration(milliseconds: 100)).then((f) {
              unread.pause();
            });
          }
          if (!isRunning()) {
            ss.resume();
            Future.delayed(Duration(seconds: 100)).then((f) {
              unread.pause();
            });
          }
        } else if (isRunning()) {
          ss.pause();
          unread.resume();
        }
      });
    } else {
      initChatStream();
    }

    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    controller.addListener(() {
      final scrollExtent = controller.position.maxScrollExtent;
      if (controller.offset == scrollExtent &&
          !oldMessagesLoadingFlag &&
          batch * batchSize <= messages.length) {
        batch++;
        initChatStream();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (ss != null) {
      ss.cancel();
    }
    if (unread != null) {
      unread.cancel();
    }
  }

  void initChatStream() async {
    oldMessagesLoadingFlag = true;
    // setState(() {
    if (ss != null) {
      await ss.cancel();
    }
    ss = widget.chatService.getChatStream(batch * batchSize).listen((event) {
      setState(() {
        messages = [];
        messages.addAll(event.documents);
        this.messageSent = messages
            .where(
                (element) => element.data['sender'] == OTPAuth.currentUser.uid)
            .length;
        if (!widget.whitelisted) {
          if (this.messageSent > 9) {
            this.nonWhitlistMessage =
                'You have reached your quota of 10 messages. Please contact your doctor to subscribe!';
          } else {
            this.nonWhitlistMessage =
                'This is a trial period you can send 10 messages to the doctor.';
          }
          setState(() {});
        }
        // if (shouldScroll) {
        //   _scrollToIndex(messages
        //       .lastIndexWhere((element) => element.data['isRead'] == false));
        //   shouldScroll = false;
        // }
        oldMessagesLoadingFlag = false;
      });
    });
  }

  _uploadImage(bool isNewChat) async {
    ImageSource _imageSource;
    await pickImageSource(context, (ImageSource imageSource) {
      _imageSource = imageSource;
    });
    if (_imageSource != null) {
      try {
        setState(() {
          _imageSendingInProcess = true;
        });
        await widget.chatService.sendImage(isNewChat, _imageSource);
      } on Exception catch (e) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
        ));
      }
      setState(() {
        _imageSendingInProcess = false;
      });
    }
  }

  _goToMedicineHistory() {
    showDialog(
        context: context,
        builder: (BuildContext bc) {
          return HistoryView(uid: widget.chatService.receiver);
        });
  }

  _previewProfile() {
    showDialog(
        context: context,
        builder: (BuildContext bc) {
          return PreviewProfile(widget._profileInfo);
        });
  }

  Future _deleteMessage(DocumentSnapshot snapshot) async {
    try {
      await snapshot.reference.delete();
      await Future.delayed(Duration(seconds: 1));
      // Scaffold.of(context).showSnackBar(SnackBar(content: Text('Deleted!')));
    } on Exception catch (e) {
      // Scaffold.of(context).showSnackBar(SnackBar(content: Text('Deletetion failed! Please try again.')));
    }
  }

  _updateUnreadStatus(MessageInfo info, DocumentReference ref) {
    if (info.isRead == false && info.sender != OTPAuth.currentUser.uid) {
      info.isRead = true;
      ref.updateData(MessageInfo.toMap(info));
    }
  }

  _scrollToIndex(int index) async {
    if (index != -1)
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await controller.scrollToIndex(index,
            preferPosition: AutoScrollPosition.end);
        controller.highlight(index);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColorPallete.textColor),
        actions: [
          if (OTPAuth.isAdmin)
            IconButton(
              icon: Icon(Icons.history),
              color: AppColorPallete.textColor,
              onPressed: () {
                _goToMedicineHistory();
              },
            )
        ],
        backgroundColor: Colors.white,
        titleSpacing: OTPAuth.isAdmin ? 0 : 10,
        title: GestureDetector(
            onTap: () {
              _previewProfile();
            },
            child: ProfileAvatar(
                OTPAuth.isAdmin ? widget.chatService.chatId : OTPAuth.adminId)),
      ),
      body: SafeArea(
        child: Container(
          color: AppColorPallete.color,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              if (!widget.whitelisted)
                Container(
                  color: AppColorPallete.textColor,
                  padding: EdgeInsets.all(5),
                  child: Text(
                    this.nonWhitlistMessage,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              Expanded(
                child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(8),
                        reverse: true,
                        itemCount: messages.length,
                        controller: controller,
                        itemBuilder: (context, index) {
                          MessageInfo info =
                              MessageInfo.fromMap(messages[index].data);
                          _updateUnreadStatus(info, messages[index].reference);
                          return AutoScrollTag(
                            key: ValueKey(index),
                            controller: controller,
                            index: index,
                            highlightColor: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: GestureDetector(
                                  onLongPress: () async {
                                    if (OTPAuth.currentUser.uid ==
                                            info.sender &&
                                        widget.whitelisted)
                                      await showModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return Container(
                                              height: 100,
                                              child: Column(
                                                children: [
                                                  FlatButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _deleteMessage(
                                                            messages[index]);
                                                      },
                                                      child: Text("Delete")),
                                                  FlatButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text("Cancel")),
                                                ],
                                              ),
                                            );
                                          });
                                  },
                                  child: MessageBubble(info),
                                ),
                              ),
                            ),
                          );
                        })),
              ),
              Visibility(
                  visible: _imageSendingInProcess,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text('Sending Image'),
                        )
                      ],
                    ),
                  )),
              if (widget.whitelisted || this.messageSent < 10)
                Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(255, 200, 200, 200),
                        spreadRadius: 2,
                        blurRadius: 5)
                  ]),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 100,
                    ),
                    child: CTextFormField(
                      maxChars: 200,
                      maxLines: null,
                      controller: _messageController,
                      prefixIcon: IconButton(
                        icon: Icon(Icons.image),
                        onPressed: () async {
                          await _uploadImage(_isNewChat);
                          widget.chatService.sendNotification(
                              'Image', widget._profileInfo.pushToken);
                        },
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          // FocusScope.of(context).unfocus();
                          if (noe(_messageController.text)) {
                            return;
                          }
                          final text = _messageController.text;
                          widget.chatService.sendMessage(text, _isNewChat);
                          widget.chatService.sendNotification(
                              text, widget._profileInfo.pushToken);
                          _messageController.text = '';
                        },
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
