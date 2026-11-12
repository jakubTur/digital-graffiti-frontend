class Drawing {

  /// ID of this drawing.
  final int? id;

  /// username of the person who created this drawing.
  final String username;

  /// ID of the parent drawing. if this is the root drawing, this should be set to -1 instead (or "null" on the remote database).
  final int parent_id;

  /// ID of the post that the drawing is under.
  /// a post can contain multiple drawings - one of them is the root, and the rest are children of other drawings.
  final int post_id;

  /// URL of the drawing image (in the database).
  final String? imageUrl;

  /// local filepath of the drawing image (used when posting the drawing).
  final String? imagePath;

  /// when the drawing was posted.
  /// backend doesn't send this, so it's nullable for now.
  final DateTime? postedAt;

  const Drawing ({
    this.id,
    required this.username,
    required this.parent_id,
    required this.post_id,
    required this.imageUrl,
    this.imagePath,
    required this.postedAt
  });
}