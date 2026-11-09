
class Post {
  final DateTime postedAt;
  final String username;
  final double latitude;
  final double longitude;
  final String? imagePath;
  final String? imageUrl;
  const Post ({
    required this.postedAt,
    required this.username,
    required this.latitude,
    required this.longitude,
    this.imagePath,
    required this.imageUrl
  });
}