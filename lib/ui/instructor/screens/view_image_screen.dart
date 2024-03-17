import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../widgets/background.dart';

class ViewImageScreen extends StatefulWidget {
  final String url;
  ViewImageScreen({this.url});
  @override
  _ViewImageScreenState createState() => _ViewImageScreenState();
}

class _ViewImageScreenState extends State<ViewImageScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Background(),
          SafeArea(
            child: PhotoView(
              backgroundDecoration: BoxDecoration(color: Colors.transparent),
              imageProvider: NetworkImage(
                widget.url,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
