import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/updated_video_analyze_screen.dart';
import '../../widgets/custom_video_thumbnail_container.dart';
import '../../../models/video.dart';
import '../../../providers/videos_provider.dart';

class VideosTabUpdatedTab extends StatefulWidget {
  @override
  _VideosTabUpdatedTabState createState() => _VideosTabUpdatedTabState();
}

class _VideosTabUpdatedTabState extends State<VideosTabUpdatedTab> {
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
      if (VideosProvider.adminUpdatedVideosLoading)
        await Provider.of<VideosProvider>(context, listen: true).subscribeAdminUpdatedVideos();
      setState(() {
        VideosProvider.adminUpdatedVideosLoading = false;
        _isLoading = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<Video> _updatedVideos =
        Provider.of<VideosProvider>(context).adminUpdatedVideos;
    List<Video> _reversed = List.from(_updatedVideos.reversed);
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
        : RefreshIndicator(
            backgroundColor: Colors.white,
            color: Colors.blue,
            onRefresh: () async {
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchAdminUpdatedVideos();
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchAdminFinalisedVideos();
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchAdminAssignedVideos();
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
                                .fetchAdminUpdatedVideos();
                            await Provider.of<VideosProvider>(context, listen: false)
                                .fetchAdminFinalisedVideos();
                            await Provider.of<VideosProvider>(context, listen: false)
                                .fetchAdminAssignedVideos();
                            await Provider.of<VideosProvider>(context, listen: false)
                                .fetchAdminWaitingVideos();
                            setState(() => _showText = true);
                          },
                          child: _showText
                              ? Text(
                                  'No videos in updated section. Tap to refresh.',
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
                                          UpdatedVideoAnalyzeScreen(
                                        _reversed.elementAt(index),
                                      ),
                                    ),
                                  ),
                                  child: CustomVideoThumbnailContainer(
                                    video: _reversed.elementAt(index),
                                    status: '',
                                    statusImagePath: '',
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
