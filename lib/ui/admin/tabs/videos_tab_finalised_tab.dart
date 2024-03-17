import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/finalised_video_analyze_page.dart';
import '../../widgets/custom_video_thumbnail_container.dart';
import '../../../models/video.dart';
import '../../../providers/videos_provider.dart';

class VideosTabFinalisedTab extends StatefulWidget {
  @override
  _VideosTabFinalisedTabState createState() => _VideosTabFinalisedTabState();
}

class _VideosTabFinalisedTabState extends State<VideosTabFinalisedTab> {
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
     // if (VideosProvider.adminFinalisedVideosLoading)
        await Provider.of<VideosProvider>(context, listen:true).subscribeAdminFinalisedVideos();
      setState(() {
        VideosProvider.adminFinalisedVideosLoading = false;
        _isLoading = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List<Video> _finalisedVideos =
        Provider.of<VideosProvider>(context).adminFinalisedVideos;
    List<Video> _reversed = List.from(_finalisedVideos.reversed);
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black)))
        : RefreshIndicator(
            backgroundColor: Colors.white,
            color: Colors.blue,
            onRefresh: () async {
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchAdminFinalisedVideos();
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchAdminAssignedVideos();
              await Provider.of<VideosProvider>(context, listen: false)
                  .fetchAdminUpdatedVideos();
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
                                .fetchAdminFinalisedVideos();
                            await Provider.of<VideosProvider>(context,
                                    listen: false)
                                .fetchAdminAssignedVideos();
                            await Provider.of<VideosProvider>(context,
                                    listen: false)
                                .fetchAdminUpdatedVideos();
                            await Provider.of<VideosProvider>(context,
                                    listen: false)
                                .fetchAdminWaitingVideos();
                            setState(() => _showText = true);
                          },
                          child: _showText
                              ? Text(
                                  'No videos in finalized section. Tap to refresh.',
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
                                          FinalisedVideoAnalyzeScreen(
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
