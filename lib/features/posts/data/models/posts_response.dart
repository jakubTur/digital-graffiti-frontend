

class PostResponse {
  final int id;
  final DateTime postedAt;
  final String username;
  final String? imageUrl;
  final double latitude;
  final double longitude;

  const PostResponse({
    required this.id,
    required this.postedAt,
    required this.username,
    required this.imageUrl,
    required this.latitude,
    required this.longitude
  });
  factory PostResponse.fromJson(Map<String, dynamic> json) {
    return PostResponse(
      id: (json['id'] as num).toInt(),
      postedAt: DateTime.parse(json['postedAt']),
      username: json['username'],
      imageUrl: json['imageUrl'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble()
    );
  }
}