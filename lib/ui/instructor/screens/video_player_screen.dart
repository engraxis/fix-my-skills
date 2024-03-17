import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../widgets/custom_title.dart';
import '../../widgets/background.dart';
import '../../../models/video.dart';
import '../../../helpers/common_functions.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Video video;
  final bool playUpdated;
  VideoPlayerScreen({@required this.video, this.playUpdated = false});
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  double _playerWidth;
  double _playerHeight;
  VideoPlayerController _videoPlayerController;
  bool _isLoading;
  bool _isRunningOnce;
  bool _isErrorLoading;

  @override
  void initState() {
    // TODO: implement initState
    _playerWidth = 0;
    _playerHeight = 0;
    _isLoading = true;
    _isRunningOnce = true;
    _isErrorLoading = false;
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    if (_isRunningOnce) {
      _isRunningOnce = false;
      _videoPlayerController = widget.playUpdated
          ? VideoPlayerController.network(widget.video.analysedVideoUrl)
          : VideoPlayerController.network(widget.video.rawVideoUrl);
      try {
        await _videoPlayerController.initialize().then((value) => setState(() {
              _isLoading = false;
            }));
      } catch (error) {
        setState(() => _isErrorLoading = true);
      }
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;
    if (!_isLoading) {
      double aspectRatio = _videoPlayerController.value.aspectRatio;
      if (aspectRatio < 1) {
        _playerWidth = CommonFunctions.videoBoxSize(context).width -
            CommonFunctions.videoBoxSize(context).width * 0.1;
        _playerHeight = _playerWidth / aspectRatio;
      } else {
        _playerWidth = CommonFunctions.videoBoxSize(context).width;
        _playerHeight = CommonFunctions.videoBoxSize(context).height;
      }
    }
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Background(),
          SafeArea(
            child: _isErrorLoading
                ? Container(
                    padding: EdgeInsets.only(
                      left: mediaQuery.width * 0.02,
                      right: mediaQuery.width * 0.02,
                      top: mediaQuery.height * 0.02,
                    ),
                    child: Column(
                      children: [
                        CustomTitle(
                          showLeading: true,
                          title: 'VIDEO PLAYER',
                          size: Size(
                            mediaQuery.width,
                            mediaQuery.height * 0.05,
                          ),
                        ),
                        SizedBox(height: mediaQuery.height * 0.4),
                        Container(
                          width: mediaQuery.width * 0.7,
                          child: Text(
                            'Sorry, there is some problem with this video.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: EdgeInsets.only(
                      left: mediaQuery.width * 0.02,
                      right: mediaQuery.width * 0.02,
                      top: mediaQuery.height * 0.02,
                    ),
                    child: _isLoading
                        ? Center(
                            child: Column(
                            children: [
                              SizedBox(height: mediaQuery.height * 0.35),
                              CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.black),
                              ),
                              SizedBox(height: 10),
                              Text('Loading video ...'),
                            ],
                          ))
                        : SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                CustomTitle(
                                  showLeading: true,
                                  title: 'VIDEO PLAYER SCREEN',
                                  size: Size(
                                    mediaQuery.width,
                                    mediaQuery.height * 0.05,
                                  ),
                                ),
                                SizedBox(height: 30),
                                Container(
                                  height: _playerHeight,
                                  width: _playerWidth,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Chewie(
                                      controller: ChewieController(
                                        videoPlayerController:
                                            _videoPlayerController,
                                        aspectRatio: _videoPlayerController
                                            .value.aspectRatio,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  widget.video.videoTitle,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  widget.video.videoNotes,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
