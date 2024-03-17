import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_downloader/flutter_downloader.dart';
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

class WaitingVideoAnalyzeScreen extends StatefulWidget {
  final Video video;
  WaitingVideoAnalyzeScreen(this.video);
  @override
  _WaitingVideoAnalyzeScreenState createState() =>
      _WaitingVideoAnalyzeScreenState();
}

class _WaitingVideoAnalyzeScreenState extends State<WaitingVideoAnalyzeScreen> {
  ReceivePort _receivePort = ReceivePort();
  bool _isDropDownClicked;
  String _selectedInstructorId;
  File _updatedVideo;
  bool _updatedVideoSelect;
  bool _updatedVideoUrlSelect;
  String _updatedVideoUrl;
  String _updatedNotes;
  bool _isRunningOnce, _isLoading;

  @override
  void initState() {
    _isDropDownClicked = false;
    _selectedInstructorId = '';
    _updatedVideoSelect = false;
    _updatedVideoUrlSelect = false;
    _isLoading = true;
    _isRunningOnce = true;
    _updatedNotes = '';
    FlutterDownloader.registerCallback(callbackFunction);
    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, CommonFunctions.DOWNLOAD_PORT_KEY);
    _receivePort.listen(
      (message) {
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
    _instructorsList.sort((a, b) => a.name.compareTo(b.name));
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
                      buildBoundary: true,
                      containerWidth:
                          CommonFunctions.videoBoxSize(context).width,
                      heightSpecified: true,
                      containerHeight:
                          CommonFunctions.videoBoxSize(context).height * 0.3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isDropDownClicked = !_isDropDownClicked;
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _selectedInstructorId.isEmpty
                                  ? buildText(
                                      text: 'Select Instructor',
                                      isBold: true,
                                    )
                                  : Row(
                                      children: [
                                        CircleAvatar(
                                          child: ClipOval(
                                            child: Image.network(
                                              _instructorsList
                                                  .firstWhere((element) =>
                                                      element.uid ==
                                                      _selectedInstructorId)
                                                  .pictureUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        buildText(
                                            text: _instructorsList
                                                .firstWhere((element) =>
                                                    element.uid ==
                                                    _selectedInstructorId)
                                                .name,
                                            isBold: true),
                                      ],
                                    ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Theme.of(context).primaryColor,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_isDropDownClicked)
                      SizedBox(height: mediaQuery.height * 0.035),
                    if (_isDropDownClicked)
                      Container(
                        height: mediaQuery.height * 0.7,
                        width: CommonFunctions.videoBoxSize(context).width,
                        child: ListView.separated(
                            itemBuilder: (ctx, index) => GestureDetector(
                                  onTap: () async {
                                    if (!_instructorsList
                                        .firstWhere((element) =>
                                            element.uid ==
                                            _instructorsList[index].uid)
                                        .access) {
                                      CommonFunctions.showToast(context,
                                          'This instructor is blocked by you.');
                                      return;
                                    }
                                    setState(() {
                                      _selectedInstructorId =
                                          _instructorsList[index].uid;
                                      _isDropDownClicked = false;
                                    });
                                  },
                                  child: CustomContainer(
                                    buildBoundary: true,
                                    containerWidth:
                                        CommonFunctions.videoBoxSize(context)
                                            .width,
                                    heightSpecified: true,
                                    containerHeight:
                                        CommonFunctions.videoBoxSize(context)
                                                .height *
                                            0.5,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            child: ClipOval(
                                              child: Image.network(
                                                _instructorsList[index]
                                                    .pictureUrl,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              buildText(
                                                  text: _instructorsList[index]
                                                      .name,
                                                  isBold: true,
                                                  isCenter: false),
                                              buildText(
                                                  text: 'Price: \$ ' +
                                                      _instructorsList[index]
                                                          .price
                                                          .toString() +
                                                      ' for 30 mins',
                                                  isBold: false),
                                              Container(
                                                height: CommonFunctions
                                                            .videoBoxSize(
                                                                context)
                                                        .height *
                                                    0.5 *
                                                    0.55,
                                                width: CommonFunctions
                                                            .videoBoxSize(
                                                                context)
                                                        .width *
                                                    0.75,
                                                child: SingleChildScrollView(
                                                  child: buildText(
                                                      text: _instructorsList[
                                                              index]
                                                          .information,
                                                      isBold: false,
                                                      isCenter: false),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            separatorBuilder: (ctx, index) =>
                                SizedBox(height: 10),
                            itemCount: _instructorsList.length),
                      ),
                    if (!_isDropDownClicked)
                      SizedBox(height: mediaQuery.height * 0.02),
                    if (!_isDropDownClicked)
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
                    if (!_isDropDownClicked)
                      SizedBox(height: mediaQuery.height * 0.02),
                    if (!_isDropDownClicked)
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
                    if (!_isDropDownClicked)
                      SizedBox(height: mediaQuery.height * 0.02),
                    if (!_isDropDownClicked)
                      CustomButton(
                          text: 'DOWNLOAD VIDEO',
                          showIcon: true,
                          icon: Icons.arrow_downward,
                          onPress: () async {
                            //CommonFunctions.showProgressDialog(context,
                            //    'Downloading video ...\nThis may take a while depending upon video size.\nVideo will download in the background.');
                            CommonFunctions.downloadVideo(
                                widget.video, context);
                            //await Future.delayed(Duration(seconds: 5));
                            //Navigator.of(context).pop();
                          }),
                    if (!_isDropDownClicked)
                      SizedBox(height: mediaQuery.height * 0.02),
                    if (!_isDropDownClicked)
                      CustomContainer(
                        containerWidth: containerWidth - 5,
                        child: Column(
                          children: [
                            SizedBox(height: 10),
                            if (_selectedInstructorId.isEmpty)
                              buildText(
                                text: 'ANALYZED VIDEO',
                                isBold: true,
                              ),
                            if (_selectedInstructorId.isEmpty)
                              SizedBox(height: 10),
                            if (_selectedInstructorId.isEmpty)
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: buildText(
                                          text: _updatedVideoSelect
                                              ? _updatedVideo.path
                                                  .split('/')
                                                  .last
                                              : 'Upload updated analyzed video'),
                                    ),
                                  ),
                                ),
                            if (_selectedInstructorId.isEmpty)
                              SizedBox(height: 10),
                            if (_selectedInstructorId.isEmpty)
                              if (_updatedVideo == null &&
                                  !_updatedVideoUrlSelect)
                                buildText(text: 'OR'),
                            if (_selectedInstructorId.isEmpty)
                              SizedBox(height: 10),
                            if (_selectedInstructorId.isEmpty)
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
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
                                CommonFunctions.showTextInputDialog(
                                        context,
                                        'Type or Paste Notes:',
                                        _selectedInstructorId.isEmpty
                                            ? ''
                                            : widget.video.videoNotes)
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
                                          : _selectedInstructorId.isEmpty
                                              ? 'Enter notes for user (optional)'
                                              : 'Edit notes for instructor, notes from user: \n' +
                                                  widget.video.videoNotes),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    SizedBox(height: 10),
                    if (!_isDropDownClicked)
                      _selectedInstructorId.isEmpty
                          ? CustomButton(
                              text: 'ACCEPT & DELIVER',
                              onPress: () async {
                                if (!_updatedVideoSelect &&
                                    !_updatedVideoUrlSelect) {
                                  CommonFunctions.showToast(
                                      context, 'Provide analyzed video.');
                                  return;
                                }
                                CommonFunctions.showProgressDialog(
                                    context, 'Sending video to client ...');
                                String upDatedVideoId = DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                                widget.video.upDatedVideoId = upDatedVideoId;
                                widget.video.status = 'completed';
                                widget.video.finalNotes = _updatedNotes;
                                widget.video.isRejected = false;
                                if (_updatedVideoUrlSelect)
                                  widget.video.isUploadedURL = true;
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
                                await Provider.of<VideosProvider>(context,
                                        listen: false)
                                    .updateVideo(widget.video);
                                CommonFunctions.createNotification(
                                    widget.video.userId,
                                    'Video delivered by Admin.',
                                    'Admin delivered your video entitled ${widget.video.videoTitle}');
                                await Provider.of<VideosProvider>(context,
                                        listen: false)
                                    .earlyAcceptAndDeliver(widget.video);
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            )
                          : CustomButton(
                              text: 'ASSIGN NOW',
                              onPress: () async {
                                widget.video.finalNotes = _updatedNotes;
                                widget.video.instructorId =
                                    _selectedInstructorId;
                                CommonFunctions.showProgressDialog(
                                    context, 'Assigning video ...');
                                await Provider.of<VideosProvider>(context,
                                        listen: false)
                                    .updateVideo(widget.video);
                                await Provider.of<VideosProvider>(context,
                                        listen: false)
                                    .assignNow(widget.video);
                                await Provider.of<InstructorsProvider>(context,
                                        listen: false)
                                    .updateInstructorStats(
                                        _instructorsList.firstWhere((element) =>
                                            element.uid ==
                                            widget.video.instructorId),
                                        true,
                                        updateActiveAssignments: true);
                                CommonFunctions.createNotification(
                                    _selectedInstructorId,
                                    'New video for analysis',
                                    'Admin sent a new video for analysis');
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
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
}
