import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:saksham_homeopathy/common/CTextFormField.dart';
import 'package:saksham_homeopathy/common/constants.dart';
import 'package:saksham_homeopathy/common/header_text.dart';
import 'package:saksham_homeopathy/common/message_bubble.dart';
import 'package:saksham_homeopathy/common/network_or_file_image.dart';
import 'package:saksham_homeopathy/home/historyPage.dart';
import 'package:saksham_homeopathy/models/profile_info.dart';
import 'package:saksham_homeopathy/services/chat_service.dart';
import 'package:saksham_homeopathy/services/otp_auth.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ChatPage extends StatefulWidget {
  final String receiver;
  Stream<QuerySnapshot> chatStream;
  ChatService chatService;
  Stream<int> unreadMessageStream;
  final Function backButton;
  ChatPage(this.receiver, {this.backButton}) {
    this.chatService = ChatService(receiver: receiver);
    this.chatStream = chatService.getChatStream();
  }

  bool isInView = false;

  void setView(val) {
    isInView = val;
    if (isInView) {
      this
          .chatService
          .chatRef
          .where('isRead', isEqualTo: false)
          .where('receiver', isEqualTo: OTPAuth.currentUser.uid)
          .getDocuments()
          .then((value) => {
                value.documents.forEach((element) {
                  element.reference.updateData({'isRead': true});
                })
              });
    }
  }

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController(text: '');

  bool _isNewChat = true;
  AutoScrollController controller;
  @override
  initState() {
    super.initState();
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await controller.scrollToIndex(7,
      //     preferPosition: AutoScrollPosition.begin);
      // controller.highlight(7);
    });
  }

  _uploadImage(bool isNewChat) async {
    await widget.chatService.sendImage(isNewChat);
  }

  _updateChangedDocument(List<DocumentChange> docChanges) {
    if (widget.isInView)
      docChanges.forEach((element) {
        if (element.document.data['sender'] == OTPAuth.currentUser.uid) return;
        if (element.document.data['isRead'] == false) {
          element.document.reference.updateData({'isRead': true});
        }
      });
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
            body: HistoryView(uid: widget.receiver),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: OTPAuth.isAdmin ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            widget.backButton(widget.receiver);
          },
        ) : null,
        actions: <Widget>[
          Visibility(
            visible: OTPAuth.isAdmin,
            child: IconButton(
              icon: Icon(Icons.history),
              onPressed: () {
                _goToMedicineHistory();
              },
            ),
          ),
          Visibility(
            visible: !OTPAuth.isAdmin,
            child: IconButton(
              icon: Icon(Icons.notification_important),
              onPressed: () async {
                await widget.chatService
                    .sendMessage(_messageController.text, _isNewChat);
                await widget.chatService
                    .sendNotification(_messageController.text);
              },
            ),
          ),
        ],
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppColorPallete.color),
        title: StreamBuilder<DocumentSnapshot>(
            stream: ChatService.getUserInfo(widget.receiver),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final _profileInfo = ProfileInfo.fromMap(snapshot.data.data);
                return Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 15,
                      child: ClipOval(
                        child: NetworkOrFileImage(
                          _profileInfo.photoUrl,
                          null,
                          _profileInfo.fileName,
                          height: double.maxFinite,
                          width: double.maxFinite,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          HeaderText(_profileInfo.displayName, size: 15),
                          // Text(
                          //   'Online',
                          //   style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          // )
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            }),
      ),
      body: Container(
        color: AppColorPallete.color,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: StreamBuilder<QuerySnapshot>(
                    stream: widget.chatStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data.documents.length > 0) {
                        _updateChangedDocument(snapshot.data.documentChanges);
                        _isNewChat = false;
                        return ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.all(8),
                            reverse: true,
                            itemCount: snapshot.data.documents.length,
                            controller: controller,
                            itemBuilder: (context, index) {
                              return AutoScrollTag(
                                key: ValueKey(index),
                                controller: controller,
                                index: index,
                                highlightColor: Colors.black.withOpacity(0.1),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    child: MessageBubble(widget.chatService
                                        .getMessageInfo(snapshot, index)),
                                  ),
                                ),
                              );
                            });
                      }
                      return Center(child: HeaderText("Start a chat."));
                    }),
              ),
            ),
            Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Color.fromARGB(255, 200, 200, 200),
                    spreadRadius: 2,
                    blurRadius: 5)
              ]),
              child: CTextFormField(
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
    );
  }
}
