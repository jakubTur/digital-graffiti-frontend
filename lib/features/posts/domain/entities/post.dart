class Post {
  final int? id;
  final DateTime postedAt;
  final String username;
  final double latitude;
  final double longitude;
  final String? imagePath;
  final String? imageUrl;
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
