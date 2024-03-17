import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:io';
import 'dart:ui';
import 'dart:isolate';

import './video_player_screen.dart';
import '../../widgets/background.dart';
import '../../widgets/custom_title.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_video_thumbnail_container.dart';
import '../../../models/video.dart';
import '../../../models/instructor.dart';
import '../../../providers/videos_provider.dart';
import '../../../providers/instructors_provider.dart';
import '../../../helpers/common_functions.dart';

class UpdatedVideoAnalyzeScreen extends StatefulWidget {
  final Video video;
  UpdatedVideoAnalyzeScreen(this.video);
  @override
  _UpdatedVideoAnalyzeScreenState createState() =>
      _UpdatedVideoAnalyzeScreenState();
}

class _UpdatedVideoAnalyzeScreenState extends State<UpdatedVideoAnalyzeScreen> {
  ReceivePort _receivePort = ReceivePort();
  File _updatedVideo;
  bool _updatedVideoSelect;
  bool _updatedVideoUrlSelect;
  String _updatedVideoUrl;
  String _updatedNotes;
  bool _isFeatured, _isLoading, _isRunningOnce;

  @override
  void initState() {
    _updatedVideoSelect = false;
    _updatedVideoUrlSelect = false;
    _updatedNotes = '';
    _isFeatured = widget.video.isFeatured;
    _isLoading = true;
    _isRunningOnce = true;
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
    if (_isRunningOnce) {
      _isRunningOnce = false;
      if (InstructorsProvider.instructorsLoading)
        await Provider.of<InstructorsProvider>(context, listen: false)
            .fetchInstructorsList();
      InstructorsProvider.instructorsLoading = false;
      setState(() => _isLoading = false);
    }
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
                          ListTile(
                            title: buildText(
                              text:
                                  'Message from ${_instructorsList.firstWhere((element) => element.uid == widget.video.instructorId).name}',
                              isBold: true,
                              isCenter: false,
                            ),
                            subtitle: buildText(
                              text: widget.video.finalNotes == null
                                  ? 'No Message'
                                  : widget.video.finalNotes.toString(),
                              isCenter: false,
                            ),
                            leading: CircleAvatar(
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
                            builder: (ctx) => VideoPlayerScreen(
                                video: widget.video, playAnalysed: true),
                          ),
                        ),
                        child: CustomVideoThumbnailContainer(
                          video: widget.video,
                          status: '',
                          statusImagePath: '',
                        ),
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
                        text: 'DOWNLOAD ORIGINAL VIDEO',
                        showIcon: true,
                        icon: Icons.arrow_downward,
                        onPress: () async {
                          CommonFunctions.downloadVideo(widget.video, context);
                        }),
                    SizedBox(height: mediaQuery.height * 0.02),
                    CustomButton(
                        text: 'DOWNLOAD ANALYZED VIDEO',
                        showIcon: true,
                        icon: Icons.arrow_downward,
                        onPress: () async {
                          if (widget.video.isUploadedURL) {
                            CommonFunctions.launchUrl(
                                widget.video.analysedVideoUrl, context);
                            return;
                          }
                          CommonFunctions.downloadVideo(widget.video, context,
                              downloadOriginal: false);
                        }),
                    SizedBox(height: mediaQuery.height * 0.02),
                    CustomContainer(
                      containerWidth: containerWidth - 5,
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          if (false) buildText(text: 'ANALYZED VIDEO'),
                          if (false) SizedBox(height: 10),
                          if (false)
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
                                          : 'Upload updated analzsed video'),
                                ),
                              ),
                            ),
                          if (false) SizedBox(height: 10),
                          if (false) buildText(text: 'OR'),
                          if (false) SizedBox(height: 10),
                          if (false)
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
                          if (false) SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              CommonFunctions.showTextInputDialog(
                                      context,
                                      'Type or Paste Notes:',
                                      widget.video.finalNotes)
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
                                      : 'Edit notes for User (Accept & Deliver). Notes from instructor:\n' +
                                          widget.video.finalNotes,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              CommonFunctions.showTextInputDialog(
                                      context,
                                      'Type or Paste Notes:',
                                      widget.video.videoNotes)
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
                                      : 'Enter notes for Instructor (Decline). Notes from user are:\n' +
                                          widget.video.videoNotes,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    SizedBox(height: mediaQuery.height * 0.02),
                    if (widget.video.isFeatured)
                      CustomContainer(
                        containerWidth: containerWidth - 5,
                        buildBoundary: false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            buildText(
                              text: 'Add to featured video',
                              isCenter: false,
                            ),
                            Switch(
                                value: _isFeatured,
                                onChanged: (value) async {
                                  print(value);
                                  CommonFunctions.showProgressDialog(
                                      context, 'Updating featured status ...');
                                  value
                                      ? await Provider.of<VideosProvider>(
                                              context,
                                              listen: false)
                                          .addFeatured(widget.video)
                                      : await Provider.of<VideosProvider>(
                                              context,
                                              listen: false)
                                          .removeFeatured(widget.video);
                                  setState(() => _isFeatured = value);
                                  Navigator.of(context).pop();
                                }),
                          ],
                        ),
                      ),
                    SizedBox(height: mediaQuery.height * 0.02),
                    Container(
                        width: containerWidth - 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              width: (containerWidth - 20) / 2,
                              text: 'DECLINE',
                              showIcon: false,
                              onPress: () async {
                                CommonFunctions.showProgressDialog(context,
                                    'Sending video back to ${_instructorsList.firstWhere((element) => element.uid == widget.video.instructorId).name} ...');
                                widget.video.isRejected = true;
                                widget.video.finalNotes = _updatedNotes;
                                await Provider.of<VideosProvider>(context,
                                        listen: false)
                                    .updateVideo(widget.video);
                                await Provider.of<VideosProvider>(context,
                                        listen: false)
                                    .decline(widget.video);
                                await Provider.of<InstructorsProvider>(context,
                                        listen: false)
                                    .updateInstructorStats(
                                        _instructorsList.firstWhere((element) =>
                                            element.uid ==
                                            widget.video.instructorId),
                                        true,
                                        updateRejected: true,
                                        updateReassignments: true);
                                CommonFunctions.createNotification(
                                    widget.video.instructorId,
                                    'Video declined',
                                    'Admin declined your video entitled ${widget.video.videoTitle}.');
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            ),
                            CustomButton(
                              width: (containerWidth - 20) / 2,
                              text: 'ACCEPT & DELIVER',
                              showIcon: false,
                              onPress: () async {
                                CommonFunctions.showProgressDialog(
                                    context, 'Sending to client ...');
                                String upDatedVideoId = DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                                if (_updatedVideoSelect ||
                                    _updatedVideoUrlSelect) {
                                  widget.video.analysedVideoUrl =
                                      _updatedVideoUrlSelect
                                          ? _updatedVideoUrl
                                          : await Provider.of<VideosProvider>(
                                                  context,
                                                  listen: false)
                                              .uploadVideo(
                                                  _updatedVideo,
                                                  widget.video.userId,
                                                  upDatedVideoId);
                                }
                                widget.video.upDatedVideoId = upDatedVideoId;
                                widget.video.status = 'completed';
                                widget.video.finalNotes = _updatedNotes;
                                widget.video.isRejected = false;
                                if (widget.video.isFeatured) {
                                  _isFeatured
                                      ? await Provider.of<VideosProvider>(
                                              context,
                                              listen: false)
                                          .addFeatured(widget.video)
                                      : await Provider.of<VideosProvider>(
                                              context,
                                              listen: false)
                                          .removeFeatured(widget.video);
                                }
                                await Provider.of<InstructorsProvider>(context,
                                        listen: false)
                                    .updateInstructorStats(
                                        _instructorsList.firstWhere((element) =>
                                            element.uid ==
                                            widget.video.instructorId),
                                        true,
                                        updateCompleted: true);
                                await Provider.of<InstructorsProvider>(context,
                                        listen: false)
                                    .updateInstructorStats(
                                        _instructorsList.firstWhere((element) =>
                                            element.uid ==
                                            widget.video.instructorId),
                                        false,
                                        updateActiveAssignments: true);
                                await Provider.of<VideosProvider>(context,
                                        listen: false)
                                    .updateVideo(widget.video);
                                await Provider.of<VideosProvider>(context,
                                        listen: false)
                                    .acceptAndDeliver(widget.video);
                                CommonFunctions.createNotification(
                                    widget.video.instructorId,
                                    'Video accepted.',
                                    'Admin accepted your video entitled ${widget.video.videoTitle}');
                                CommonFunctions.createNotification(
                                    widget.video.userId,
                                    'Video delivered by Admin.',
                                    'Admin delivered your video entitled ${widget.video.videoTitle}');
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        )),
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
