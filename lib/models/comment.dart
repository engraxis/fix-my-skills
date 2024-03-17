import 'package:flutter/foundation.dart';

class Comment {
  String commenterName;
  String commenterPicUrl;
  String comment;

  Comment({
    @required this.commenterName,
    @required this.commenterPicUrl,
    @required this.comment,
  });

  Map<String, dynamic> toMap() {
    return {
      'commenterName': this.commenterName,
      'commenterPicUrl': this.commenterPicUrl,
      'comment': this.comment,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return new Comment(
      commenterName: map['commenterName'] as String,
      commenterPicUrl: map['commenterPicUrl'] as String,
      comment: map['comment'] as String,
    );
  }

  static List<Map<String, dynamic>> listCommentToListMap(
      List<Comment> comments) {
    List<Map<String, dynamic>> ret = [];
    for (var comment in comments) ret.add(comment.toMap());
    return ret;
  }

  static List<Comment> dynamicMapTocommentMap(comments) {
    List<Comment> ret = [];
    for (var comment in comments) ret.add(Comment.fromMap(comment));
    return ret;
  }
}
