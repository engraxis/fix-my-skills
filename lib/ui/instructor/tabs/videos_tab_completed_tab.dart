import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/completed_video_analyze_screen.dart';
import '../../widgets/custom_video_thumbnail_container.dart';
import '../../../models/video.dart';
import '../../../providers/videos_provider.dart';
import '../../../helpers/common_functions.dart';

class VideosTabCompletedTab extends StatefulWidget {
  @override
  _VideosTabCompletedTabState createState() => _VideosTabCompletedTabState();
}

class _VideosTabCompletedTabState extends State<VideosTabCompletedTab> {
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
      // if (VideosProvider.instructorCompletedVideosLoading)
      /*await */ Provider.of<VideosProvider>(context, listen: true)
          .subscribeInstructorCompletedVideos();
      //.fetchInstructorCompletedVideos();
      setState(() {
        VideosProvider.instructorCompletedVideosLoading = false;
        _isLoading = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<Video> _completedVideos =
        Provider.of<VideosProvider>(context, listen: true)
            .instructorsCompletedVideos;
    List<Video> _reversed = List.from(_completedVideos.reversed);
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
        : RefreshIndicator(
            onRefresh: () async {
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchInstructorCompletedVideos();
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchInstructorWaitingVideos();
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
                                .fetchInstructorCompletedVideos();
                            await Provider.of<VideosProvider>(context,
                                    listen: false)
                                .fetchInstructorWaitingVideos();
                            setState(() => _showText = true);
                          },
                          child: _showText
                              ? Text(
                                  'No videos in completed section. Tap to refresh.',
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
                                  onTap: () => Navigator.of(ctx).push(
                                    MaterialPageRoute(
                                      builder: (ctx) =>
                                          CompletedVideoAnalyzeScreen(
                                        _reversed.elementAt(index),
                                      ),
                                    ),
                                  ),
                                  child: CustomVideoThumbnailContainer(
                                    video: _reversed.elementAt(index),
                                    status: 'completed',
                                    statusImagePath: 'assets/completed.png',
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
