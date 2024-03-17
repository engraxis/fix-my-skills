import 'package:flutter/foundation.dart';
import './comment.dart';

class Video {
  String videoId,
      userId,
      instructorId,
      rawVideoUrl,
      updatedVideoUrl,
      analysedVideoUrl,
      videoThumbnailUrl,
      videoTitle,
      videoNotes,
      promoCode,
      finalNotes,
      status,
      upDatedVideoId;
  bool isFeatured, isRejected, isUpdated, isUploadedURL;
  List<Comment> comments;
  int totalLength;
  double totalCost;


  Video({
    @required this.videoId,
    @required this.userId,
    @required this.instructorId,
    @required this.rawVideoUrl,
    this.analysedVideoUrl = '',
    @required this.videoThumbnailUrl,
    @required this.videoTitle,
    @required this.videoNotes,
    @required this.promoCode,
    @required this.isFeatured,
    @required this.status,
    this.finalNotes = '',
    this.isRejected = false,
    @required this.comments,
    @required this.totalLength,
    this.totalCost = 0.0,
    this.isUpdated = false,
    this.updatedVideoUrl = '',
    this.isUploadedURL = false,
    @required this.upDatedVideoId,
  });

  Map<String, dynamic> toMap() {
    return {
      'videoId': this.videoId,
      'userId': this.userId,
      'instructorId': this.instructorId,
      'rawVideoUrl': this.rawVideoUrl,
      'analysedVideoUrl': this.analysedVideoUrl,
      'imageUrl': this.videoThumbnailUrl,
      'videoTitle': this.videoTitle,
      'videoNotes': this.videoNotes,
      'promoCode': this.promoCode,
      'isFeatured': this.isFeatured,
      'status': this.status,
      'finalNotes': this.finalNotes,
      'isRejected': this.isRejected,
      'comments': Comment.listCommentToListMap(this.comments),
      'totalLength': this.totalLength,
      'totalCost': this.totalCost,
      'isUpdated': this.isUpdated,
      'updatedVideoUrl': this.updatedVideoUrl,
      'isUploadedURL': this.isUploadedURL,
      'upDatedVideoId': this.upDatedVideoId,
    };
  }

  factory Video.fromMap(Map<String, dynamic> map) {
    return new Video(
      videoId: map['videoId'] as String,
      userId: map['userId'] as String,
      instructorId: map['instructorId'] as String,
      rawVideoUrl: map['rawVideoUrl'] as String,
      analysedVideoUrl: map['analysedVideoUrl'] as String,
      updatedVideoUrl: map['updatedVideoUrl'] as String,
      videoThumbnailUrl: map['imageUrl'] as String,
      videoTitle: map['videoTitle'] as String,
      videoNotes: map['videoNotes'] as String,
      promoCode: map['promoCode'] as String,
      isFeatured: map['isFeatured'] as bool,
      isUpdated: map['isUpdated'] as bool,
      status: map['status'] as String,
      finalNotes: map['finalNotes'] as String,
      isRejected: map['isRejected'] as bool,
      comments: Comment.dynamicMapTocommentMap(map['comments']),
      totalLength: map['totalLength'] as int,
      totalCost: map['totalCost'].toDouble() as double,
      isUploadedURL: map['isUploadedURL'] as bool,
      upDatedVideoId: map['upDatedVideoId'] as String,
    );
  }
}
