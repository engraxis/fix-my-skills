import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import './view_image_screen.dart';
import '../../widgets/background.dart';
import '../../../helpers/message_helper.dart';
import '../../../helpers/common_functions.dart';
import '../../../models/message.dart';
import '../../../res/static_info.dart';
import '../../../res/keys.dart';

class ChatDetailScreen extends StatefulWidget {
  final String uid, name;

  ChatDetailScreen(this.uid, this.name);

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  TextEditingController msgCon = TextEditingController();

  MessageHelper helper;
  var subscription;

  List<Message> messages;
  bool loading = false;
  String productImg;
  bool image = false;
  DateTime lastMsgTime;

  @override
  void initState() {
    print('0000000000000000000000000000.......................');
    print(widget.uid);
    super.initState();
    msgRead();
    helper = MessageHelper.withMsgStreamInitialized(widget.uid);
    subscription = helper.messageStream.listen((data) {
      setState(() {
        messages = data;
      });
    });
  }

  msgRead() async => await Firestore.instance
      .collection(Keys.admin)
      .document(StaticInfo.currentUser.uid)
      .collection(Keys.myChats)
      .document(widget.uid)
      .setData({"newMsg": false}, merge: true);

  @override
  void dispose() {
    subscription.cancel();
    helper.dispose();
    super.dispose();
  }

  getTime(String msg) =>
      DateTime.fromMicrosecondsSinceEpoch(int.parse(msg)).toLocal();

  checkDay(int index) {
    String date;
    var last = messages[messages.length - 1 - index].msgId;
    var first = messages[messages.length - 2 - index].msgId;
    var f = DateTime.fromMicrosecondsSinceEpoch(int.parse(first)).toLocal();
    var l = DateTime.fromMicrosecondsSinceEpoch(int.parse(last)).toLocal();
    if (int.parse(f.toString().substring(9, 10)) >
        int.parse(l.toString().substring(9, 10))) {
      date = f.toString().substring(0, 10);
    }

    return date;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context, widget.name, msgRead),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  Background(),
                  messages == null
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Column(
                          children: <Widget>[
                            loading
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: CircularProgressIndicator(),
                                  )
                                : Container(),
                            Expanded(
                              child: ListView.builder(
                                reverse: true,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                itemCount: messages.length,
                                itemBuilder: (_, index) {
                                  var message =
                                      messages[messages.length - 1 - index];

                                  return Align(
                                    alignment: message.senderUid ==
                                            StaticInfo.currentUser.uid
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: message.image
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 7),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        ViewImageScreen(
                                                      url: message.url,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Color(0xff4F93F5),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  10)),
                                                      // color: Colors.blue
                                                    ),
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.3,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                    child: Stack(
                                                      fit: StackFit.expand,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(40.0),
                                                          child: Container(
                                                            // color: Colors.red,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.28,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.55,
                                                            // child: SpinKitPulse(
                                                            //   color: Colors
                                                            //       .blue[800],
                                                            //   size: 150.0,
                                                            // ),
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                                        ),
                                                        ClipRRect(
                                                          child: Image.network(
                                                            message.url,
                                                            fit: BoxFit.fill,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(getTime(message.msgId)
                                                      .toString()
                                                      .substring(11, 16)),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 7),
                                            child: Column(
                                              // crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Theme.of(context)
                                                            .accentColor,
                                                        width: 2,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: message
                                                                  .senderUid ==
                                                              StaticInfo
                                                                  .currentUser
                                                                  .uid
                                                          ? Color(0xff4F93F5)
                                                          : Colors.white),
                                                  child: Text(
                                                    message.msgBody,
                                                    style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.037,
                                                      color: message
                                                                  .senderUid ==
                                                              StaticInfo
                                                                  .currentUser
                                                                  .uid
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Text(TimeConverter(
                                                    getTime(message.msgId)
                                                        .toString()
                                                        .substring(11, 16))),
                                              ],
                                            ),
                                          ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextField(
                                      controller: msgCon,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: 'Type message here',
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 5, horizontal: 20),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  InkWell(
                                    onTap: () {
                                      var picked;
                                      showDialog(
                                          context: context,
                                          builder: (ctx) {
                                            return AlertDialog(
                                              title: Text(
                                                  'Pick one source for image'),
                                              actions: [
                                                FlatButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);

                                                      picked = await ImagePicker
                                                          .pickImage(
                                                              source:
                                                                  ImageSource
                                                                      .gallery, imageQuality: 40);
                                                      if (picked != null) {
                                                        var cropped =
                                                            await ImageCropper
                                                                .cropImage(
                                                          sourcePath:
                                                              picked.path,
                                                          compressQuality: 70,
                                                          aspectRatio:
                                                              CropAspectRatio(
                                                                  ratioX: 1,
                                                                  ratioY: 1),
                                                        );
                                                        if (cropped != null)
                                                          setState(() {
                                                            image = true;
                                                            productImg =
                                                                cropped.path;
                                                          });
                                                      }
                                                    },
                                                    child: Text('Gallery')),
                                                FlatButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      picked = await ImagePicker
                                                          .pickImage(
                                                              source:
                                                                  ImageSource
                                                                      .camera, imageQuality: 40);
                                                      if (picked != null) {
                                                        var cropped =
                                                            await ImageCropper
                                                                .cropImage(
                                                          sourcePath:
                                                              picked.path,
                                                          compressQuality: 40,
                                                          aspectRatio:
                                                              CropAspectRatio(
                                                                  ratioX: 1,
                                                                  ratioY: 1),
                                                        );
                                                        if (cropped != null)
                                                          setState(() {
                                                            print("rr");
                                                            image = true;
                                                            productImg =
                                                                cropped.path;
                                                          });

                                                        _sendMsg();
                                                      }
                                                    },
                                                    child: Text('Camera'))
                                              ],
                                            );
                                          });
                                    },
                                    child: CircleAvatar(
                                      radius: 28,
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  FloatingActionButton(
                                    onPressed: () {
                                      productImg = null;
                                      _sendMsg();
                                    },
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    child: Icon(Icons.send),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _sendMsg() async {
    if (msgCon.text.isEmpty && image == false) return;

    Message message = Message(
        msgId: DateTime.now().toUtc().microsecondsSinceEpoch.toString(),
        msgBody: msgCon.text.trim(),
        senderUid: StaticInfo.currentUser.uid,
        receiverUid: widget.uid,
        usersUidsMerge: StaticInfo.currentUser.uid + widget.uid,
        image: productImg != null ? true : false,
        url: productImg);
    lastMsgTime = DateTime.fromMicrosecondsSinceEpoch(
            int.parse(DateTime.now().toUtc().microsecondsSinceEpoch.toString()))
        .toLocal();
    CommonFunctions.createNotification(
        widget.uid, 'New Message from Admin', message.msgBody);
    setState(() {
      msgCon.clear();
    });

    await helper.sentMessage(message, lastMsgTime);
    //await helper.notifyMessage(widget.uid);
  }

  String TimeConverter(String time) {
    String notiTime;
    List l = time.split(":");
    int intial2 = int.parse(l[0]);
    if (l[1].length < 2) {
      print(l[1]);
      l[1] = "0${l[1]}";
    }
    if (intial2 == 12) {
      notiTime = intial2.toString() + ":" + l[1] + " P.M";
    } else if (intial2 == 0) {
      notiTime = "12:${l[1]} A.M";
    } else {
      notiTime =
          '${intial2 > 12 ? (intial2 - 12).toString() + ":" + l[1] + " P.M" : intial2.toString() + ":" + l[1] + " A.M"}';
    }

    return notiTime;
  }
}

PreferredSizeWidget _appBar(
    BuildContext context, String name, Function msgRead) {
  return PreferredSize(
    child: SafeArea(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).accentColor,
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                msgRead();
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Theme.of(context).primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_back_ios_sharp,
                  color: Colors.black,
                ),
              ),
            ),
            Text(
              name,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: MediaQuery.of(context).size.width * 0.06),
            ),
          ],
        ),
      ),
    ),
    preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.12),
  );
}
