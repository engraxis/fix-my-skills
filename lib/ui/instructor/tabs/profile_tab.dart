import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import '../screens/edit_profile_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_title.dart';
import '../../auth/login.dart';
import '../../../res/keys.dart';
import '../../../res/static_info.dart';
import '../../../helpers/common_functions.dart';
import '../../../helpers/message_helper.dart';
import '../../../providers/videos_provider.dart';
import '../../../providers/instructors_provider.dart';
import '../../../providers/appointments_provider.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String privacyLink, termsLink, faqLink;
  bool _isRunningOnce;
  bool _isDataLoading;
  bool _goOffline;

  @override
  void initState() {
    _isRunningOnce = true;
    _isDataLoading = true;
    _goOffline = StaticInfo.currentUser.isOffline ?? false;
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    // TODO: implement didChangeDependencies
    if (_isRunningOnce) {
      _isRunningOnce = false;
      _isDataLoading = true;
      if (VideosProvider.instructorCompletedVideosLoading)
        await Provider.of<VideosProvider>(context, listen: false)
            .fetchInstructorCompletedVideos();
      VideosProvider.instructorCompletedVideosLoading = false;
      var links = await Provider.of<VideosProvider>(context, listen: false).getLinks();
      faqLink = links.elementAt(0);
      privacyLink = links.elementAt(1);
      termsLink = links.elementAt(2);
      setState(() {
        _isDataLoading = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            left: mediaQuery.width * 0.1,
            right: mediaQuery.width * 0.1,
            top: mediaQuery.height * 0.03,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CustomTitle(
                showLeading: false,
                title: 'PROFILE',
                size: Size(
                  mediaQuery.width,
                  mediaQuery.height * 0.05,
                ),
              ),
              SizedBox(height: mediaQuery.height * 0.03),
              InkWell(
                onTap: () async {
                  var url = privacyLink.startsWith('http')
                      ? privacyLink
                      : 'https://$privacyLink';
                  if (await canLaunch(url)) await launch(url);
                },
                child: CustomStaticText(text: 'Privacy Policy Link'),
              ),
              SizedBox(height: mediaQuery.height * 0.01),
              InkWell(
                onTap: () async {
                  var url = termsLink.startsWith('http')
                      ? termsLink
                      : 'https://$termsLink';
                  if (await canLaunch(url)) await launch(url);
                },
                child: CustomStaticText(text: 'Terms & Conditions Link'),
              ),
              SizedBox(height: mediaQuery.height * 0.01),
              InkWell(
                onTap: () async {
                  var url = termsLink.startsWith('http')
                      ? faqLink
                      : 'https://$faqLink';
                  if (await canLaunch(url)) await launch(url);
                },
                child: CustomStaticText(text: 'FAQ Link'),
              ),
              SizedBox(height: mediaQuery.height * 0.03),
              CustomStaticText(
                text: 'Total Completed',
                trailingWidget: _isDataLoading
                    ? Text('Wait', style: TextStyle(color: Colors.white))
                    : Text(StaticInfo.currentUser.totalCompleted.toString(),
                        style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: mediaQuery.height * 0.01),
              CustomStaticText(
                text: 'Total Rejected by Admin',
                trailingWidget: Text(
                    StaticInfo.currentUser.totalRejected == null
                        ? '0'
                        : StaticInfo.currentUser.totalRejected.toString(),
                    style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: mediaQuery.height * 0.01),
              CustomStaticText(
                text: 'Total Waiting',
                trailingWidget: _isDataLoading
                    ? Text('Wait', style: TextStyle(color: Colors.white))
                    : Text(
                        StaticInfo.currentUser.totalActiveAssignments
                            .toString(),
                        style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: mediaQuery.height * 0.03),
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) =>
                        EditProfileScreen(StaticInfo.currentUser))),
                child: CustomStaticText(
                  text: 'Update Profile',
                  trailingWidget: Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(height: mediaQuery.height * 0.01),
              GestureDetector(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  StaticInfo.currentUser = null;
                  await OneSignal.shared
                      .sendTag(StaticInfo.currentUser.uid, "no");
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => Login()), (_) => false);
                },
                child: CustomStaticText(
                  text: 'Go Offline for Private Lesson',
                  trailingWidget: Switch(
                    value: _goOffline,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.black12,
                    inactiveTrackColor: Colors.black12,
                    onChanged: (value) async {
                      CommonFunctions.showProgressDialog(
                          context, 'Changing Online Status ...');
                      await Provider.of<InstructorsProvider>(context,
                              listen: false)
                          .setInstructorOnlineStatus(
                              value, StaticInfo.currentUser.uid);
                      Navigator.of(context).pop();
                      setState(() => _goOffline = value);
                    },
                  ),
                ),
              ),
              SizedBox(height: mediaQuery.height * 0.03),
              CustomButton(
                text: 'LOGOUT',
                width: mediaQuery.width * 0.7,
                onPress: () async {
                  CommonFunctions.showProgressDialog(
                      context, 'Logging out ...');
                  await OneSignal.shared
                      .sendTag(StaticInfo.currentUser.uid, "no");
                  await FirebaseAuth.instance.signOut();
                  StaticInfo.currentUser = null;
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => Login()), (_) => false);
                },
              ),
              SizedBox(height: mediaQuery.height * 0.01),
              CustomButton(
                text: 'DELETE ACCOUNT',
                width: mediaQuery.width * 0.7,
                onPress: _delete,
              ),
              SizedBox(height: mediaQuery.height * 0.01),
            ],
          ),
        ),
      ),
    );
  }

  Text buildText(String text, BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: MediaQuery.of(context).size.width * 0.036,
          fontWeight: FontWeight.w500),
    );
  }

  _delete() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Warning!'),
        content: Text('Are you sure you want to delete your account?'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No'),
          ),
          FlatButton(
            onPressed: () async {
              CommonFunctions.showProgressDialog(
                  context, 'Deleting your account ...');
              await OneSignal.shared.sendTag(StaticInfo.currentUser.uid, "no");
              await Firestore.instance
                  .collection(Keys.users)
                  .document(StaticInfo.currentUser.uid)
                  .delete();

              await Provider.of<VideosProvider>(context, listen: false)
                  .instructorWaitingVideosReturn(StaticInfo.currentUser);

              MessageHelper.deleteUserChat(StaticInfo.currentUser.uid);

              await Provider.of<AppointmentsProvider>(context, listen: false)
                  .deleteAllAppointments(StaticInfo.currentUser.uid);

              await FirebaseAuth.instance.signOut();
              StaticInfo.currentUser = null;
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => Login()), (_) => false);
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
}

class CustomStaticText extends StatelessWidget {
  final String text;
  final Icon icon;
  final Widget trailingWidget;

  CustomStaticText({
    @required this.text,
    this.icon,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: CommonFunctions.textFieldHeight(context) * 0.8,
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(width: 15),
          icon == null
              ? Container()
              : Icon(Icons.email, color: Theme.of(context).primaryColor),
          icon == null ? SizedBox(width: 0) : SizedBox(width: 15),
          Text(
            text,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: MediaQuery.of(context).size.width * 0.7 * 0.045,
            ),
          ),
          Spacer(),
          trailingWidget ?? Container(),
          SizedBox(width: 15),
        ],
      ),
    );
  }
}
