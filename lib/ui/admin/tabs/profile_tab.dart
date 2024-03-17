import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../widgets/custom_title.dart';
import '../../../res/static_info.dart';
import '../../../res/keys.dart';
import '../../../helpers/common_functions.dart';
import '../../../ui/auth/login.dart';
import '../../../ui/widgets/custom_container.dart';
import '../../../ui/widgets/custom_button.dart';

class ProfileTab extends StatefulWidget {
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  String _privacyLink;
  String _termsLink;
  String _faqLink;
  double _pricePerVideo;
  double _pricePerSecond;
  int _videoTimeLimit;
  double _allTimeEarnings;

  @override
  void initState() {
    _privacyLink = '';
    _termsLink = '';
    _faqLink = '';
    _pricePerVideo = 0.0;
    _pricePerSecond = 0.0;
    _videoTimeLimit = 0;
    _allTimeEarnings = 0.0;

    Firestore.instance.collection(Keys.config).snapshots().listen((event) {
      event.documents.forEach((doc) {
        if (doc.documentID == Keys.links) {
          _privacyLink = doc.data[Keys.privacyLink];
          _faqLink = doc.data[Keys.faqLink];
          _termsLink = doc.data[Keys.termsLink];
        }
        if (doc.documentID == Keys.prices) {
          _pricePerVideo = doc.data[Keys.pricePerVideo].toDouble();
          _pricePerSecond = doc.data[Keys.pricePerSecond].toDouble();
        }
        if (doc.documentID == Keys.videos) {
          _videoTimeLimit = doc.data[Keys.videoTimeLimit].toDouble();
        }
        if (doc.documentID == Keys.allTimeEarnings) {
          _allTimeEarnings = doc.data[Keys.allTimeEarnings].toDouble();
        }
        setState(() {});
      });
    });

    /*Firestore.instance.collection(Keys.config).getDocuments().then((value) {
      for (var doc in value.documents) {
       
      }
      setState(() {});
    });*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          left: mediaQuery.width * 0.1,
          right: mediaQuery.width * 0.1,
          top: mediaQuery.height * 0.03,
        ),
        width: mediaQuery.width,
        child: SingleChildScrollView(
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
                  await CommonFunctions.showTextInputDialog(
                          context, 'Privacy Policy Link', _privacyLink ?? '')
                      .then((value) async {
                    if (value == null) return;
                    _privacyLink = value;
                    CommonFunctions.showProgressDialog(
                        context, 'Privacy Policy Link');
                    await Firestore.instance
                        .collection(Keys.config)
                        .document(Keys.links)
                        .setData({Keys.privacyLink: _privacyLink}, merge: true);
                    Navigator.of(context).pop();
                    setState(() {});
                  });
                },
                child: CustomContainer(
                  containerWidth: mediaQuery.width * 0.7,
                  buildBoundary: false,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 7),
                    alignment: Alignment.center,
                    child: _privacyLink == null || _privacyLink == ''
                        ? buildText('Set Privacy Policy Link', context)
                        : buildText('Privacy Policy Link', context),
                  ),
                ),
              ),
              SizedBox(height: mediaQuery.height * 0.01),
              InkWell(
                onTap: () async {
                  await CommonFunctions.showTextInputDialog(
                          context, 'Terms & Conditions Link', _termsLink ?? '')
                      .then((value) async {
                    if (value == null) return;
                    _termsLink = value;
                    CommonFunctions.showProgressDialog(
                        context, 'Updating Terms & Conditions Link');
                    await Firestore.instance
                        .collection(Keys.config)
                        .document(Keys.links)
                        .setData({Keys.termsLink: _termsLink}, merge: true);
                    Navigator.of(context).pop();
                    setState(() {});
                  });
                },
                child: CustomContainer(
                  containerWidth: mediaQuery.width * 0.7,
                  buildBoundary: false,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 7),
                    alignment: Alignment.center,
                    child: _termsLink == null || _termsLink == ''
                        ? buildText('Set Terms & Conditions Link', context)
                        : buildText('Terms & Conditions Link', context),
                  ),
                ),
              ),
              SizedBox(height: mediaQuery.height * 0.01),
              InkWell(
                onTap: () async {
                  await CommonFunctions.showTextInputDialog(
                          context, 'FAQ Link', _faqLink ?? '')
                      .then((value) async {
                    if (value == null) return;
                    _faqLink = value;
                    CommonFunctions.showProgressDialog(context, 'FAQ Link');
                    await Firestore.instance
                        .collection(Keys.config)
                        .document(Keys.links)
                        .setData({Keys.faqLink: _faqLink}, merge: true);
                    Navigator.of(context).pop();
                    setState(() {});
                  });
                },
                child: CustomContainer(
                  containerWidth: mediaQuery.width * 0.7,
                  buildBoundary: false,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 7),
                    alignment: Alignment.center,
                    child: _faqLink == null || _faqLink == ''
                        ? buildText('Set FAQ Link', context)
                        : buildText('FAQ Link', context),
                  ),
                ),
              ),
              SizedBox(height: mediaQuery.height * 0.04),
              InkWell(
                  onTap: () async {
                    await CommonFunctions.showTextInputDialog(
                            context,
                            'Video Time Limit\n(seconds)',
                            _videoTimeLimit == null
                                ? ''
                                : _videoTimeLimit.toString())
                        .then((value) async {
                      if (value == null) return;
                      _videoTimeLimit = int.parse(value);
                      CommonFunctions.showProgressDialog(
                          context, 'Updating video time limit ...');
                      await Firestore.instance
                          .collection(Keys.config)
                          .document(Keys.videos)
                          .setData({Keys.videoTimeLimit: _videoTimeLimit},
                              merge: true);
                      Navigator.of(context).pop();
                      setState(() {});
                    });
                  },
                  child: _videoTimeLimit == null || _videoTimeLimit == 0
                      ? CustomRow('Set Video Time Limit', '')
                      : CustomRow('Video Time Limit', '$_videoTimeLimit s')),
              SizedBox(height: mediaQuery.height * 0.01),
              CustomRow(
                  'All Time Earning', '\$ ${_allTimeEarnings.toStringAsFixed(2)}'),
              SizedBox(height: mediaQuery.height * 0.04),
              CustomContainer(
                containerWidth: mediaQuery.width * 0.7,
                buildBoundary: true,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      SizedBox(height: mediaQuery.height * 0.01),
                      InkWell(
                        onTap: () async {
                          await CommonFunctions.showTextInputDialog(
                                  context,
                                  'Price per Video (\$)',
                                  _pricePerVideo == null
                                      ? ''
                                      : _pricePerVideo.toString())
                              .then((value) async {
                            if (value == null) return;
                            _pricePerVideo = double.parse(value);
                            CommonFunctions.showProgressDialog(
                                context, 'Updating price per video ...');
                            await Firestore.instance
                                .collection(Keys.config)
                                .document(Keys.prices)
                                .setData({Keys.pricePerVideo: _pricePerVideo},
                                    merge: true);
                            Navigator.of(context).pop();
                            setState(() {});
                          });
                        },
                        child: _pricePerVideo == null || _pricePerVideo == 0.0
                            ? CustomRow('Set Price per Video', '')
                            : CustomRow(
                                'Price per Video',
                                _pricePerVideo == null
                                    ? '\$0'
                                    : '\$$_pricePerVideo'),
                      ),
                      SizedBox(height: mediaQuery.height * 0.01),
                      InkWell(
                          onTap: () async {
                            await CommonFunctions.showTextInputDialog(
                                    context,
                                    'Price per Second (\$)',
                                    _pricePerSecond == null
                                        ? ''
                                        : _pricePerSecond.toString())
                                .then((value) async {
                              if (value == null) return;
                              _pricePerSecond = double.parse(value);
                              CommonFunctions.showProgressDialog(
                                  context, 'Updating price per second ...');
                              await Firestore.instance
                                  .collection(Keys.config)
                                  .document(Keys.prices)
                                  .setData(
                                      {Keys.pricePerSecond: _pricePerSecond},
                                      merge: true);
                              Navigator.of(context).pop();
                              setState(() {});
                            });
                          },
                          child:
                              _pricePerSecond == null || _pricePerSecond == 0.0
                                  ? CustomRow('Set Price per Second', '')
                                  : CustomRow(
                                      'Price per Second',
                                      _pricePerSecond == null
                                          ? '\$0'
                                          : '\$$_pricePerSecond')),
                      SizedBox(height: mediaQuery.height * 0.01),
                    ],
                  ),
                ),
              ),
              SizedBox(height: mediaQuery.height * 0.04),
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
                        MaterialPageRoute(builder: (_) => Login()),
                        (_) => false);
                  }),
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
      height: CommonFunctions.textFieldHeight(context),
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

class CustomRow extends StatelessWidget {
  final String leadingText;
  final String trailingText;

  CustomRow(
    this.leadingText,
    this.trailingText,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: CommonFunctions.textFieldHeight(context),
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(width: 15),
          Text(
            leadingText,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          Spacer(),
          Text(
            trailingText,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(width: 15),
        ],
      ),
    );
  }
}
