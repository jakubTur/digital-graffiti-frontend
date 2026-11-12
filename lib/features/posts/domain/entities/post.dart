class Post {

  /// ID uniquely identifying this post.
  final int? id;

  /// when this post was created.
  final DateTime postedAt;

  /// who created this post.
  final String username;

  ///IRL coordinates of post:
  ///
  final double latitude;
  final double longitude;

  /// local path of the post's background image. used when uploading the post.
  final String? imagePath;

  /// remote URL of this post.
  final String? imageUrl;

  /// note: a post is just a background image (for example: taken via camera or blank).
  /// the drawing itself needs to be posted separately as a Drawing referencing this post.

  const Post({
    this.id,
    required this.postedAt,
    required this.username,
    required this.latitude,
    required this.longitude,
    this.imagePath,
    required this.imageUrl,
  });
}
