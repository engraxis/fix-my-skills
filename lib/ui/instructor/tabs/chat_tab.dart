import 'package:flutter/material.dart';

import '../screens/chat_detail_screen.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_title.dart';
import '../../../models/chat.dart';
import '../../../helpers/message_helper.dart';
import '../../../helpers/auth_helper.dart';

class ChatTab extends StatefulWidget {
  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  bool notify = false;
  String s;
  var subscription;
  MessageHelper helper;
  List<Chat> chats = [];
  List<Chat> _chatsToDisplay = [];

  int index = 0;

  @override
  void initState() {
    helper = MessageHelper.withChatStreamInitialized(isAdmin: false);
    subscription = helper.chatStream.listen((data) {
      setState(() {
        chats = data;
        chats.sort((b, a) => a.dateTime.compareTo(b.dateTime));
        _chatsToDisplay.clear();
        _chatsToDisplay.addAll(chats);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final widthAfterPadding =
        mediaQuery.width - mediaQuery.width * 0.05 - mediaQuery.width * 0.05;
    final containerHeight = mediaQuery.height * 0.09;
    final containerWidth = widthAfterPadding;
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: mediaQuery.width * 0.05,
          right: mediaQuery.width * 0.05,
          top: mediaQuery.height * 0.03,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CustomTitle(
              showLeading: false,
              title: 'CHAT',
              size: Size(
                mediaQuery.width,
                mediaQuery.height * 0.05,
              ),
            ),
            SizedBox(height: mediaQuery.height * 0.03),
            CustomContainer(
              buildBoundary: true,
              heightSpecified: true,
              containerWidth: containerWidth,
              containerHeight: containerHeight * 0.7,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: containerWidth * 0.7,
                height: containerHeight * 0.7,
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search Person',
                    hintStyle: TextStyle(color: Colors.white),
                    isDense: true,
                    suffixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    contentPadding: EdgeInsets.all(0),
                  ),
                  maxLines: 1,
                  style: TextStyle(color: Colors.white),
                  onChanged: (val) {
                    setState(() {
                      if (val.isEmpty) {
                        _chatsToDisplay.clear();
                        _chatsToDisplay.addAll(chats);
                      } else {
                        _chatsToDisplay.clear();
                        _chatsToDisplay.addAll(
                          chats.where(
                            (element) => element.name
                                .toUpperCase()
                                .contains(val.toUpperCase()),
                          ),
                        );
                      }
                    });
                  },
                ),
              ),
            ),
            if (_chatsToDisplay
                    .firstWhere(
                        (element) => element.uid == AuthHelper.ADMIN_UID,
                        orElse: () => Chat(null, null, null, null))
                    .name ==
                null)
              SizedBox(height: mediaQuery.height * 0.03),
            if (_chatsToDisplay
                    .firstWhere(
                        (element) => element.uid == AuthHelper.ADMIN_UID,
                        orElse: () => Chat(null, null, null, null))
                    .name ==
                null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).accentColor,
                ),
                child: Center(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) => ChatDetailScreen(
                          AuthHelper.ADMIN_UID, AuthHelper.ADMIN_NAME),
                    )),
                    child: ListTile(
                      isThreeLine: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      title: buildText(
                        context,
                        'Admin',
                        MediaQuery.of(context).size.height * 0.02,
                        isBold: true,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                  itemBuilder: (ctx, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).accentColor,
                      ),
                      child: Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (ctx) => ChatDetailScreen(
                                      _chatsToDisplay.elementAt(index).uid,
                                      _chatsToDisplay.elementAt(index).name))),
                          child: ListTile(
                            isThreeLine: false,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            title: buildText(
                                context,
                                _chatsToDisplay.elementAt(index).name,
                                MediaQuery.of(context).size.height * 0.02),
                            trailing: Container(
                              width: widthAfterPadding * 0.2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _chatsToDisplay.elementAt(index).newMsg ==
                                          null
                                      ? Container()
                                      : _chatsToDisplay.elementAt(index).newMsg
                                          ? Icon(Icons.fiber_new,
                                              color: Theme.of(context)
                                                  .primaryColor)
                                          : Container(),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (ctx, index) {
                    return SizedBox(height: 10);
                  },
                  itemCount: _chatsToDisplay.length),
            ),
          ],
        ),
      ),
    );
  }

  Text buildText(BuildContext context, String text, double textSize,
      {bool isBold = false}) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontSize: textSize,
      ),
    );
  }
}
