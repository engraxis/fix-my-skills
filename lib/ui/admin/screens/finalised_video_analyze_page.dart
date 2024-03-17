import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import './video_player_screen.dart';
import '../../widgets/background.dart';
import '../../widgets/custom_title.dart';
import '../../widgets/custom_container.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_video_thumbnail_container.dart';
import '../../../helpers/common_functions.dart';
import '../../../models/video.dart';
import '../../../models/instructor.dart';
import '../../../providers/instructors_provider.dart';
import '../../../providers/videos_provider.dart';

class FinalisedVideoAnalyzeScreen extends StatefulWidget {
  final Video video;
  FinalisedVideoAnalyzeScreen(this.video);
  @override
  _FinalisedVideoAnalyzeScreenState createState() =>
      _FinalisedVideoAnalyzeScreenState();
}

class _FinalisedVideoAnalyzeScreenState
    extends State<FinalisedVideoAnalyzeScreen> {
  ReceivePort _receivePort = ReceivePort();
  bool _isFeatured;
  String _updatedNotes;
  File _updatedVideo;
  bool _updatedVideoSelect;
  bool _updatedVideoUrlSelect;
  String _updatedVideoUrl;
  bool _isRunningOnce, _isLoading;

  @override
  void initState() {
    _updatedVideoSelect = false;
    _updatedVideoUrlSelect = false;
    _isFeatured = widget.video.isFeatured;
    _updatedNotes = '';
    _isLoading = true;
    _isRunningOnce = true;

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
                    if (widget.video.finalNotes != null &&
                        widget.video.finalNotes.isNotEmpty)
                      if (widget.video.instructorId.isNotEmpty)
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
                    if (widget.video.finalNotes != null &&
                        widget.video.finalNotes.isNotEmpty)
                      SizedBox(height: mediaQuery.height * 0.02),
                    Container(
                      width: CommonFunctions.videoBoxSize(context).width,
                      height: CommonFunctions.videoBoxSize(context).height,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: GestureDetector(
                        onTap: () => widget.video.isUploadedURL
                            ? widget.video.updatedVideoUrl.isEmpty
                                ? CommonFunctions.launchUrl(
                                    widget.video.analysedVideoUrl, context)
                                : CommonFunctions.launchUrl(
                                    widget.video.updatedVideoUrl, context)
                            : Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => VideoPlayerScreen(
                                    video: widget.video,
                                    playAnalysed:
                                        widget.video.isUpdated ? false : true,
                                    playUpdated:
                                        widget.video.isUpdated ? true : false,
                                  ),
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
                            widget.video.updatedVideoUrl.isNotEmpty
                                ? CommonFunctions.launchUrl(
                                    widget.video.updatedVideoUrl, context)
                                : CommonFunctions.launchUrl(
                                    widget.video.analysedVideoUrl, context);
                            return;
                          }
                          CommonFunctions.downloadVideo(widget.video, context,
                              downloadOriginal: false,
                              downloadUpdated: widget.video.isUpdated);
                        }),
                    SizedBox(height: mediaQuery.height * 0.02),
                    CustomContainer(
                      containerWidth: containerWidth - 5,
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          buildText(text: 'ANALYZED VIDEO'),
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
                                          : 'Upload updated analyzed video'),
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
                              CommonFunctions.showTextInputDialog(
                                      context,
                                      'Type or Paste Thanking Notes:',
                                      _updatedNotes)
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
                                      : 'Enter thanking notes for User (Optional)',
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
                                activeColor: Colors.white,
                                activeTrackColor: Colors.grey,
                                inactiveThumbColor: Colors.black,
                                inactiveTrackColor: Colors.grey,
                                onChanged: (value) async {
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

                                  Navigator.of(context).pop();
                                  setState(() {
                                    _isFeatured = value;
                                  });
                                }),
                          ],
                        ),
                      ),
                    if (widget.video.isFeatured)
                      SizedBox(height: mediaQuery.height * 0.02),
                    CustomButton(
                      text: 'UPDATE',
                      onPress: () async {
                        CommonFunctions.showProgressDialog(
                            context, 'Updating ...');
                        widget.video.analysedVideoUrl =
                            widget.video.updatedVideoUrl;
                        String upDatedVideoId =
                            DateTime.now().millisecondsSinceEpoch.toString();

                        if (_updatedVideoSelect || _updatedVideoUrlSelect) {
                          if (_updatedVideoUrlSelect) {
                            widget.video.analysedVideoUrl = _updatedVideoUrl;
                          } else {
                            widget.video.analysedVideoUrl =
                                await Provider.of<VideosProvider>(context,
                                        listen: false)
                                    .uploadVideo(_updatedVideo,
                                        widget.video.userId, upDatedVideoId);
                            widget.video.upDatedVideoId = upDatedVideoId;
                          }
                        }
/*
                          widget.video.analysedVideoUrl = _updatedVideoUrlSelect
                              ? _updatedVideoUrl
                              : await Provider.of<VideosProvider>(context,
                                      listen: false)
                                  .uploadVideo(_updatedVideo,
                                      widget.video.userId, upDatedVideoId);
                        }
                        widget.video.upDatedVideoId = upDatedVideoId;
                        */
                        if (_updatedNotes.isNotEmpty)
                          widget.video.finalNotes = _updatedNotes;
                        widget.video.isUpdated = false;
                        widget.video.updatedVideoUrl = '';
                        widget.video.isUploadedURL =
                            _updatedVideoUrlSelect ? true : false;
                        if (widget.video.isFeatured) {
                          _isFeatured
                              ? await Provider.of<VideosProvider>(context,
                                      listen: false)
                                  .addFeatured(widget.video)
                              : await Provider.of<VideosProvider>(context,
                                      listen: false)
                                  .removeFeatured(widget.video);
                        }
                        await Provider.of<VideosProvider>(context,
                                listen: false)
                            .updateVideo(widget.video);

                        CommonFunctions.createNotification(
                            widget.video.instructorId,
                            'Video updated.',
                            'Admin updated your video entitled ${widget.video.videoTitle}');
                        CommonFunctions.createNotification(
                            widget.video.userId,
                            'Video updated by Admin.',
                            'Admin udpated your video entitled ${widget.video.videoTitle}');
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
