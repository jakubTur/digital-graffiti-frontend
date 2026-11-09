
class DrawingResponse {
  final int id;
  final String username;
  final int postId;
  final int parentId;
  final String imageUrl;
  final DateTime postedAt;
  const DrawingResponse ({
    required this.id,
    required this.username,
    required this.postId,
    required this.parentId,
    required this.imageUrl,
    required this.postedAt
  });
  factory DrawingResponse.fromJson(Map<String, dynamic> json) {
    return DrawingResponse(
      id: (json['id'] as num).toInt(),
      username: json['username'],
      postId: (json['postId'] as num).toInt(),
      parentId: (json['originId'] as num).toInt(),
      imageUrl: json['imageUrl'],
      postedAt: DateTime.parse(json['createdAt'])
    );
  }
}