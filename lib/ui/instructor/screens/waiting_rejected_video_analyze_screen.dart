import 'dart:isolate';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:image_picker/image_picker.dart';

import './video_player_screen.dart';
import '../../widgets/background.dart';
import '../../widgets/custom_title.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_video_thumbnail_container.dart';
import '../../../models/video.dart';
import '../../../providers/videos_provider.dart';
import '../../../providers/instructors_provider.dart';
import '../../../helpers/common_functions.dart';
import '../../../helpers/auth_helper.dart';
import '../../../res/static_info.dart';

class WaitingRejectedVideoAnalyzeScreen extends StatefulWidget {
  final Video video;
  WaitingRejectedVideoAnalyzeScreen(this.video);
  @override
  _WaitingRejectedVideoAnalyzeScreenState createState() =>
      _WaitingRejectedVideoAnalyzeScreenState();
}

class _WaitingRejectedVideoAnalyzeScreenState
    extends State<WaitingRejectedVideoAnalyzeScreen> {
  ReceivePort _receivePort = ReceivePort();
  File _updatedVideo;
  bool _updatedVideoSelect;
  bool _updatedVideoUrlSelect;
  String _updatedVideoUrl;
  String _updatedNotes;

  @override
  void initState() {
    _updatedVideoSelect = false;
    _updatedVideoUrlSelect = false;
    _updatedNotes = '';

    FlutterDownloader.registerCallback(callbackFunction);
    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, CommonFunctions.DOWNLOAD_PORT_KEY);
    _receivePort.listen(
      (message) {
        // CommonFunctions.showToast(
        //     context, 'Downloading progress: ${message[2]} %', 25);
        if (message[1] == DownloadTaskStatus.complete)
          CommonFunctions.showToast(context, 'Download finished.', 1);

        if (message[1] == DownloadTaskStatus.failed)
          CommonFunctions.showToast(context, 'Downloading failed.');

        if (message[1] == DownloadTaskStatus.undefined)
          CommonFunctions.showToast(context, 'Downloading failed.');
      },
    );
    super.initState();
  }

  static callbackFunction(id, status, progress) {
    SendPort sendPort =
        IsolateNameServer.lookupPortByName(CommonFunctions.DOWNLOAD_PORT_KEY);
    sendPort.send([id, status, progress]);
  }

  @override
  void dispose() {
    _receivePort.close();
    IsolateNameServer.removePortNameMapping(CommonFunctions.DOWNLOAD_PORT_KEY);
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;
    final widthAfterPadding =
        mediaQuery.width - mediaQuery.width * 0.05 - mediaQuery.width * 0.05;
    final containerWidth = widthAfterPadding;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Background(),
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  left: mediaQuery.width * 0.05,
                  right: mediaQuery.width * 0.05,
                  top: mediaQuery.height * 0.03,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CustomTitle(
                      showLeading: true,
                      title: 'ANALYSE VIDEO',
                      size: Size(
                        mediaQuery.width,
                        mediaQuery.height * 0.05,
                      ),
                    ),
                    SizedBox(height: mediaQuery.height * 0.02),
                    CustomContainer(
                      containerWidth: widthAfterPadding,
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          buildText(
                            text: 'Message from Admin',
                            isBold: true,
                            isCenter: false,
                          ),
                          SizedBox(height: 10),
                          buildText(
                            text: widget.video.finalNotes == null
                                ? 'No Message'
                                : widget.video.finalNotes.toString(),
                            isCenter: false,
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    SizedBox(height: mediaQuery.height * 0.02),
                    Container(
                      width: CommonFunctions.videoBoxSize(context).width,
                      height: CommonFunctions.videoBoxSize(context).height,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => VideoPlayerScreen(
                              video: widget.video,
                              playUpdated: true,
                            ),
                          ),
                        ),
                        child: CustomVideoThumbnailContainer(
                            video: widget.video,
                            status: 'waiting', // widget.video.status,
                            statusImagePath: 'assets/waiting.png'),
                      ),
                    ),
                    SizedBox(height: mediaQuery.height * 0.02),
                    CustomContainer(
                      containerWidth: mediaQuery.width,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildRow('Name', widget.video.videoTitle,
                              containerWidth - 5, context),
                          buildRow('Video Notes', widget.video.videoNotes,
                              containerWidth - 5, context),
                          buildRow(
                              'Video Length',
                              '${widget.video.totalLength}' + ' s',
                              containerWidth - 5,
                              context),
                          buildRow('Total Cost', '\$ ${widget.video.totalCost}',
                              containerWidth - 5, context),
                          buildRow(
                              'Feature Permission',
                              widget.video.isFeatured ? 'Yes' : 'No',
                              containerWidth - 5,
                              context),
                        ],
                      ),
                    ),
                    SizedBox(height: mediaQuery.height * 0.02),
                    CustomButton(
                      text: 'DOWNLOAD VIDEO',
                      showIcon: true,
                      icon: Icons.arrow_downward,
                      onPress: () async {
                         CommonFunctions.downloadVideo(widget.video, context);
                         /*
                        CommonFunctions.showProgressDialog(context,
                            'Downloading video ...\nThis may take a while depending upon video size.\nVideo will download in the background.');
                        CommonFunctions.downloadVideo(widget.video, context);
                        await Future.delayed(Duration(seconds: 5));
                        Navigator.of(context).pop();*/
                      },
                    ),
                    SizedBox(height: mediaQuery.height * 0.02),
                    CustomContainer(
                      containerWidth: containerWidth - 5,
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          buildText(
                            text: 'ANALYZED VIDEO',
                            isBold: true,
                          ),
                          SizedBox(height: 10),
                          if (!_updatedVideoUrlSelect)
                            GestureDetector(
                              onTap: () async {
                                _updatedVideo = await ImagePicker.pickVideo(
                                  source: ImageSource.gallery,
                                );
                                setState(() {
                                  _updatedVideo;
                                  _updatedVideoSelect =
                                      _updatedVideo == null ? false : true;
                                });
                              },
                              child: CustomContainer(
                                containerWidth: containerWidth * 0.8,
                                buildBoundary: false,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: buildText(
                                      text: _updatedVideoSelect
                                          ? _updatedVideo.path.split('/').last
                                          : 'Upload updated analzsed video'),
                                ),
                              ),
                            ),
                          SizedBox(height: 10),
                          if (_updatedVideo == null && !_updatedVideoUrlSelect)
                            buildText(text: 'OR'),
                          SizedBox(height: 10),
                          if (_updatedVideo == null)
                            GestureDetector(
                              onTap: () async {
                                CommonFunctions.showTextInputDialog(
                                        context,
                                        'Type or Paste Link: \nStart with www',
                                        _updatedVideoUrl)
                                    .then((value) => setState(() {
                                          if (value != null) {
                                            _updatedVideoUrl =
                                                value.contains('http')
                                                    ? value
                                                    : 'https://' + value;
                                            _updatedVideoUrlSelect = true;
                                          }
                                        }));
                              },
                              child: CustomContainer(
                                containerWidth: containerWidth * 0.8,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: buildText(
                                      text: _updatedVideoUrlSelect
                                          ? _updatedVideoUrl
                                          : 'Paste analyzed video link'),
                                ),
                              ),
                            ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              CommonFunctions.showTextInputDialog(context,
                                      'Type or Paste Notes:', _updatedNotes)
                                  .then((value) => setState(() {
                                        if (value != null) {
                                          _updatedNotes = value;
                                        }
                                      }));
                            },
                            child: CustomContainer(
                              containerWidth: containerWidth * 0.8,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: buildText(
                                    text: _updatedNotes.isNotEmpty
                                        ? _updatedNotes
                                        : 'Enter any notes for Admin (Optional).'),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          CustomButton(
                            width: containerWidth * 0.8,
                            text: 'SEND TO ADMIN',
                            onPress: () async {
                              if (!_updatedVideoSelect &&
                                  !_updatedVideoUrlSelect) {
                                CommonFunctions.showToast(
                                    context, 'Provide analyzed video.');
                                return;
                              }

                              CommonFunctions.showProgressDialog(
                                  context, 'Sending video to Admin ...');
                                  String upDatedVideoId = DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                                    widget.video.upDatedVideoId = upDatedVideoId;
                              widget.video.finalNotes = _updatedNotes;
                              widget.video.isRejected = false;
                              widget.video.isUploadedURL =
                                  _updatedVideoUrlSelect ? true : false;
                              widget.video.analysedVideoUrl =
                                  _updatedVideoUrlSelect
                                      ? _updatedVideoUrl
                                      : await Provider.of<VideosProvider>(
                                              context,
                                              listen: false)
                                          .uploadVideo(_updatedVideo,
                                              widget.video.userId, upDatedVideoId);
                              await Provider.of<VideosProvider>(context,
                                      listen: false)
                                  .updateVideo(widget.video);
                              await Provider.of<VideosProvider>(context,
                                      listen: false)
                                  .sendToAdmin(widget.video);
                              await Provider.of<InstructorsProvider>(context,
                                      listen: false)
                                  .updateInstructorStats(
                                      StaticInfo.currentUser, false,
                                      updateReassignments: true);
                              CommonFunctions.createNotification(
                                  AuthHelper.ADMIN_UID,
                                  'New updated video received',
                                  '${StaticInfo.currentUser.name} sent a new analyzed video.');
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text buildText({
    String text,
    bool isBold = false,
    bool isCenter = true,
  }) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
      textAlign: isCenter ? TextAlign.center : TextAlign.left,
    );
  }

  Row buildRow(String textLeft, String textRight, double containerWidth,
      BuildContext context) {
    return Row(
      children: [
        Container(
          width: containerWidth * 0.5 - 10,
          child: Text(
            textLeft,
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(width: 20),
        Container(
          width: containerWidth * 0.5 - 10,
          child: Text(
            textRight,
            maxLines: 4,
            style: TextStyle(color: Theme.of(context).primaryColor),
            textAlign: TextAlign.left,
          ),
        )
      ],
    );
  }

  showProgressDialog(BuildContext context, String title) {
    return showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text(title),
            content: Container(
              height: MediaQuery.of(context).size.height / 15,
              width: MediaQuery.of(context).size.width / 10,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                    Colors.black,
                  ),
                ),
              ),
            ),
          );
        });
  }
}
