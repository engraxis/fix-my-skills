import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/waiting_video_analyze_screen.dart';
import '../../widgets/custom_video_thumbnail_container.dart';
import '../../../models/video.dart';
import '../../../providers/videos_provider.dart';
import '../../../providers/instructors_provider.dart';

class VideosTabWaitingTab extends StatefulWidget {
  @override
  _VideosTabWaitingTabState createState() => _VideosTabWaitingTabState();
}

class _VideosTabWaitingTabState extends State<VideosTabWaitingTab> {
  bool _isRunningOnce;
  bool _isLoading;
  bool _showText;

  @override
  void initState() {
    _isRunningOnce = true;
    _isLoading = true;
    _showText = true;
    if (this.mounted) super.initState();
  }

  @override
  void didChangeDependencies() async {
    if (_isRunningOnce) {
      _isRunningOnce = false;
      _isLoading = true;
      /*while (InstructorsProvider.instructorsLoading)
        await Future.delayed(Duration(milliseconds: 100));*/
      if (VideosProvider.adminWaitingVideosLoading)
        await Provider.of<VideosProvider>(context, listen: true)
            .subscribeAdminWaitingVideos();
      setState(() {
        VideosProvider.adminWaitingVideosLoading = false;
        _isLoading = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<Video> _waitingVideos =
        Provider.of<VideosProvider>(context, listen: true).adminWaitingVideos;
    List<Video> _reversed = List.from(_waitingVideos.reversed);
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
        : RefreshIndicator(
            backgroundColor: Colors.white,
            color: Colors.blue,
            onRefresh: () async {
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchAdminWaitingVideos();
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchAdminAssignedVideos();
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchAdminUpdatedVideos();
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchAdminFinalisedVideos();
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
                                .fetchAdminWaitingVideos();
                            await Provider.of<VideosProvider>(context, listen: false)
                                .fetchAdminAssignedVideos();
                            await Provider.of<VideosProvider>(context, listen: false)
                                .fetchAdminUpdatedVideos();
                            await Provider.of<VideosProvider>(context, listen: false)
                                .fetchAdminFinalisedVideos();
                            setState(() => _showText = true);
                          },
                          child: _showText
                              ? Text(
                                  'No videos in waiting section. Tap to refresh.',
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
                                      Colors.black)),
                        ),
                      )
                    : Container(
                        child: ListView.separated(
                            itemBuilder: (ctx, index) => GestureDetector(
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) =>
                                          WaitingVideoAnalyzeScreen(
                                        _reversed.elementAt(index),
                                      ),
                                    ),
                                  ),
                                  child: CustomVideoThumbnailContainer(
                                    video: _reversed.elementAt(index),
                                    status: 'waiting',
                                    statusImagePath: 'assets/waiting.png',
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
