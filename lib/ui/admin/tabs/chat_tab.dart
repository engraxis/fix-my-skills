import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/chat_detail_screen.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_title.dart';
import '../../../models/chat.dart';
import '../../../models/instructor.dart';
import '../../../helpers/message_helper.dart';
import '../../../helpers/common_functions.dart';
import '../../../providers/instructors_provider.dart';

class ChatTab extends StatefulWidget {
  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  var subscription;
  MessageHelper helper;
  List<Chat> chats = [];
  List<Chat> _chatsToDisplay = [];
  bool _isRunningOnce, _isLoading;

  @override
  void initState() {
    _isRunningOnce = true;
    _isLoading = true;
    helper = MessageHelper.withChatStreamInitialized(isAdmin: true);
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
  void didChangeDependencies() async {
    if (_isRunningOnce) {
      _isRunningOnce = false;
      if (InstructorsProvider.instructorsLoading)
        await Provider.of<InstructorsProvider>(context, listen: false)
            .fetchInstructorsList(showAll: true);
      InstructorsProvider.instructorsLoading = false;
      setState(() => _isLoading = false);
    }
    super.didChangeDependencies();
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
    List<Instructor> _instructorsList =
        Provider.of<InstructorsProvider>(context, listen: true).instructorsList;

    MessageHelper.deletedInstructorsUids.forEach((instructorUid) {
      _chatsToDisplay.removeWhere((element) => element.uid == instructorUid);
    });
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
                child: TextField(
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search Instructor',
                    hintStyle: TextStyle(color: Colors.white),
                    isDense: true,
                    suffixIcon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                  maxLines: 1,
                  style: TextStyle(color: Colors.white),
                  onChanged: (val) {
                    _chatsToDisplay.clear();
                    setState(() {
                      if (val.isEmpty) {
                        _chatsToDisplay.clear();
                        _chatsToDisplay.addAll(chats);
                        MessageHelper.deletedInstructorsUids
                            .forEach((instructorUid) {
                          print(instructorUid);
                        });
                        MessageHelper.deletedInstructorsUids
                            .forEach((instructorUid) {
                          _chatsToDisplay.removeWhere(
                              (element) => element.uid == instructorUid);
                        });
                      } else {
                        _chatsToDisplay.clear();
                        _chatsToDisplay.addAll(
                          chats.where(
                            (element) => element.name
                                .toUpperCase()
                                .contains(val.toUpperCase()),
                          ),
                        );
                        MessageHelper.deletedInstructorsUids
                            .forEach((instructorUid) {
                          _chatsToDisplay.removeWhere(
                              (element) => element.uid == instructorUid);
                        });
                      }
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: mediaQuery.height * 0.03),
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
                          onTap: () {
                            // if (!_instructorsList
                            //     .firstWhere((element) =>
                            //         element.uid ==
                            //         _chatsToDisplay.elementAt(index).uid)
                            //     .access) {
                            //   CommonFunctions.showToast(context,
                            //       'This instructor is blocked by you.');
                            //   return;
                            // }
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (ctx) {
                              return ChatDetailScreen(
                                  _chatsToDisplay.elementAt(index).uid,
                                  _chatsToDisplay.elementAt(index).name);
                            }));
                          },
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
