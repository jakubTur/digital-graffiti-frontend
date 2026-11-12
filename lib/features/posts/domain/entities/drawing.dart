class Drawing {
  final int id;
  final String username;
  final int parent_id;
  final int post_id;
  final String? imageUrl;
  final String? imagePath;
  final DateTime postedAt;
  const Drawing ({
    required this.id,
    required this.username,
    required this.parent_id,
    required this.post_id,
    required this.imageUrl,
    this.imagePath,
    required this.postedAt
  });
}