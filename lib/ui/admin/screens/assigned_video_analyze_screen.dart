import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:isolate';
import 'package:flutter_downloader/flutter_downloader.dart';

import './video_player_screen.dart';
import '../../widgets/background.dart';
import '../../widgets/custom_title.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_video_thumbnail_container.dart';
import '../../../models/video.dart';
import '../../../models/instructor.dart';
import '../../../helpers/common_functions.dart';
import '../../../providers/instructors_provider.dart';
import '../../../providers/videos_provider.dart';

class AssignedVideoAnalyzeScreen extends StatefulWidget {
  final Video video;
  AssignedVideoAnalyzeScreen(this.video);
  @override
  _AssignedVideoAnalyzeScreenState createState() =>
      _AssignedVideoAnalyzeScreenState();
}

class _AssignedVideoAnalyzeScreenState
    extends State<AssignedVideoAnalyzeScreen> {
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
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<Instructor> _instructorsList =
        Provider.of<InstructorsProvider>(context, listen: true).instructorsList;
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
                    SizedBox(height: mediaQuery.height * 0.03),
                    CustomContainer(
                      containerWidth: mediaQuery.width,
                      child: Column(
                        children: [
                          buildText(text: 'ASSIGNED INSTRUCTOR'),
                          SizedBox(height: 10),
                          CircleAvatar(
                            radius: 40,
                            child: ClipOval(
                              child: Image.network(
                                _instructorsList
                                    .firstWhere((element) =>
                                        element.uid ==
                                        widget.video.instructorId)
                                    .pictureUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          buildText(
                            text: _instructorsList
                                .firstWhere((element) =>
                                    element.uid == widget.video.instructorId)
                                .name,
                            isBold: true,
                          ),
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
                            builder: (ctx) =>
                                VideoPlayerScreen(video: widget.video),
                          ),
                        ),
                        child: CustomVideoThumbnailContainer(
                            video: widget.video,
                            status: widget.video.status,
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
                          buildRow(
                              'Video Length',
                              widget.video.totalLength.toString() + ' s',
                              containerWidth - 5,
                              context),
                          buildRow(
                              'Total Cost',
                              '\$ ' + widget.video.totalCost.toString(),
                              containerWidth - 5,
                              context),
                          buildRow(
                              'Feature Permission',
                              widget.video.isFeatured ? 'Yes' : 'No',
                              containerWidth - 5,
                              context),
                          buildRow('Notes', widget.video.videoNotes,
                              containerWidth - 5, context),
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
                        }),
                    if (false) SizedBox(height: mediaQuery.height * 0.02),
                    if (false)
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
                            GestureDetector(
                              onTap: () async {
                                _updatedVideo = await ImagePicker.pickVideo(
                                  source: ImageSource.gallery,
                                );
                                setState(() => _updatedVideoSelect =
                                    _updatedVideo == null ? false : true);
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
                                          : 'Upload updated analyzed video'),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            buildText(text: 'OR'),
                            SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                CommonFunctions.showTextInputDialog(context,
                                        'Type or Paste Link:', _updatedVideoUrl)
                                    .then((value) => setState(() {
                                          if (value != null) {
                                            _updatedVideoUrl = value;
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
                                          : 'Enter notes for instructor (Optional)'),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    SizedBox(height: 10),
                    CustomButton(
                        text: 'CANCEL ASSIGNMENT',
                        onPress: () async {
                          if (!await CommonFunctions.yesNoDialog(
                              context, 'Are you sure to cancel the video?'))
                            return;

                          CommonFunctions.showProgressDialog(
                              context, 'Cancelling assignment ...');
                          String instructorId = widget.video.instructorId;
                          await Provider.of<VideosProvider>(context,
                                  listen: false)
                              .cancelAssignment(widget.video);
                          widget.video.instructorId = '';
                          widget.video.isRejected = false;
                          await Provider.of<VideosProvider>(context,
                                  listen: false)
                              .updateVideo(widget.video);
                          CommonFunctions.createNotification(
                              instructorId,
                              'Video cancelled to analyze',
                              'Admin cancelled the video entitled: ${widget.video.videoTitle}');
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }),
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
