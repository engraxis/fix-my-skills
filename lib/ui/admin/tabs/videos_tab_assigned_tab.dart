import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/assigned_video_analyze_screen.dart';
import '../../widgets/custom_video_thumbnail_container.dart';
import '../../../models/video.dart';
import '../../../providers/videos_provider.dart';
import '../../../providers/instructors_provider.dart';

class VideosTabAssignedTab extends StatefulWidget {
  @override
  _VideosTabAssignedTabState createState() => _VideosTabAssignedTabState();
}

class _VideosTabAssignedTabState extends State<VideosTabAssignedTab> {
  bool _isRunningOnce;
  bool _isLoading;
  bool _showText;

  @override
  void initState() {
    _isRunningOnce = true;
    _isLoading = true;
    _showText = true;
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    if (_isRunningOnce) {
      _isRunningOnce = false;
      _isLoading = true;
      while (InstructorsProvider.instructorsLoading)
        await Future.delayed(Duration(seconds: 1));
      if (VideosProvider.adminAssignedVideosLoading)
        await Provider.of<VideosProvider>(context, listen: true)
            .subscribeAdminAssignedVideos();
      // await Provider.of<VideosProvider>(context, listen: false)
      //     .fetchAdminAssignedVideos();
      VideosProvider.adminAssignedVideosLoading = false;
      if (mounted)
        setState(() {
          _isLoading = false;
        });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<Video> _assignedVideos =
        Provider.of<VideosProvider>(context, listen: true).adminAssignedVideos;
    List<Video> _reversed = List.from(_assignedVideos.reversed);
    _reversed.forEach((element) {
      print(element.videoId);
    });
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
        : RefreshIndicator(
            backgroundColor: Colors.white,
            color: Colors.blue,
            onRefresh: () async {
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchAdminAssignedVideos();
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchAdminUpdatedVideos();
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchAdminFinalisedVideos();
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchAdminWaitingVideos();
            },
            child: Stack(
              children: [
                _reversed.length == 0
                    ? Center(
                        child: GestureDetector(
                          onTap: () async {
                            setState(() => _showText = false);
                            await Provider.of<VideosProvider>(context,
                                    listen: false)
                                .fetchAdminAssignedVideos();
                            await Provider.of<VideosProvider>(context,
                                    listen: false)
                                .fetchAdminUpdatedVideos();
                            await Provider.of<VideosProvider>(context,
                                    listen: false)
                                .fetchAdminFinalisedVideos();
                            await Provider.of<VideosProvider>(context,
                                    listen: false)
                                .fetchAdminWaitingVideos();
                            setState(() => _showText = true);
                          },
                          child: _showText
                              ? Text(
                                  'No videos in assigned section. Tap to refresh.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.06,
                                  ),
                                )
                              : CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.black),
                                ),
                        ),
                      )
                    : Container(
                        child: ListView.separated(
                            itemBuilder: (ctx, index) => GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) =>
                                          AssignedVideoAnalyzeScreen(
                                        _reversed.elementAt(index),
                                      ),
                                    ),
                                  ),
                                  child: CustomVideoThumbnailContainer(
                                    video: _reversed.elementAt(index),
                                    status: 'waiting',
                                    statusImagePath: 'assets/waiting.png',
                                    showInstructor: true,
                                  ),
                                ),
                            separatorBuilder: (ctx, _) => SizedBox(height: 10),
                            itemCount: _reversed.length),
                      ),
              ],
            ),
          );
  }
}
