import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:saksham_homeopathy/common/CTextFormField.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
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
  final ProfileInfo _profileInfo;
  ChatPage(this.chatService, this._profileInfo);

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
  bool isInView = true;
  // int lastUnreadIndex;

  @override
  initState() {
    super.initState();
    initChatStream();

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
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   int lastUnreadIndex = messages.lastIndexWhere((element) => element.data['isRead'] == false);
    //   if (lastUnreadIndex != null || lastUnreadIndex !=) {

    //   }
    // });
  }

  void initChatStream() async {
    oldMessagesLoadingFlag = true;
    setState(() {
      chatStream = widget.chatService.getChatStream(batch * batchSize);
    });
    oldMessagesLoadingFlag = false;
  }

  void loadOldMessages(DocumentSnapshot afterSnapshot) {
    oldMessagesLoadingFlag = true;
    widget.chatService.getOldMessages(afterSnapshot).then((value) {
      setState(() {
        messages.addAll(value.documentChanges.map((e) => e.document));
      });
      oldMessagesLoadingFlag = false;
    });
  }

  _uploadImage(bool isNewChat) async {
    ImageSource _imageSource;
    await showModalBottomSheet(
        context: context,
        builder: (context) => ImageSourceBottomSheet((ImageSource imageSource) {
              _imageSource = imageSource;
            }));
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
          return Scaffold(
            appBar: AppBar(
              // backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: AppColorPallete.backgroundColor),
            ),
            body: HistoryView(uid: widget.chatService.receiver),
          );
        });
  }

  _previewProfile() {
    showDialog(
        context: context,
        builder: (BuildContext bc) {
          return Scaffold(
            appBar: AppBar(
              // backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: AppColorPallete.backgroundColor),
            ),
            body: PreviewProfile(widget._profileInfo),
          );
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
    if (info.isRead == false &&
        info.sender != OTPAuth.currentUser.uid &&
        isInView) {
      info.isRead = true;
      ref.updateData(MessageInfo.toMap(info));
    }
  }

  _scrollToIndex(int index) async {
    if (index != -1)
      await controller.scrollToIndex(index,
          preferPosition: AutoScrollPosition.end);
    controller.highlight(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: StreamBuilder<QuerySnapshot>(
                      stream: chatStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          bool shouldScroll = messages.length == 0;
                          messages = [];
                          messages.addAll(snapshot.data.documents);
                          if (shouldScroll) {
                            _scrollToIndex(messages.lastIndexWhere(
                                (element) => element.data['isRead'] == false));
                          }
                          if (messages.length == 0) {
                            return Center(child: HeaderText("Start a chat."));
                          }
                          return ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.all(8),
                              reverse: true,
                              itemCount: messages.length,
                              controller: controller,
                              itemBuilder: (context, index) {
                                MessageInfo info =
                                    MessageInfo.fromMap(messages[index].data);
                                _updateUnreadStatus(
                                    info, messages[index].reference);
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
                                              info.sender)
                                            await showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return Container(
                                                    height: 100,
                                                    child: Column(
                                                      children: [
                                                        FlatButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                              _deleteMessage(
                                                                  messages[
                                                                      index]);
                                                            },
                                                            child:
                                                                Text("Delete")),
                                                        FlatButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child:
                                                                Text("Cancel")),
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
                              });
                        } else {
                          return Container();
                        }
                      }),
                ),
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
              Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: Color.fromARGB(255, 200, 200, 200),
                      spreadRadius: 2,
                      blurRadius: 5)
                ]),
                child: CTextFormField(
                  maxChars: 200,
                  controller: _messageController,
                  prefixIcon: IconButton(
                    icon: Icon(Icons.image),
                    onPressed: () async {
                      await _uploadImage(_isNewChat);
                    },
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      // FocusScope.of(context).unfocus();
                      if (noe(_messageController.text)) {
                        return;
                      }
                      widget.chatService
                          .sendMessage(_messageController.text, _isNewChat);
                      _messageController.text = '';
                    },
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
