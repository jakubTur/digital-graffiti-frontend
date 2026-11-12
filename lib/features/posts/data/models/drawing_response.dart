
class DrawingResponse {
  final int id;
  final String username;
  final int postId;
  final int parentId; // set to -1 for drawings parented directly to post.
  final String? imageUrl; // null until the drawing's image upload has finished.
  final DateTime? postedAt; // backend doesn't send createdAt for drawings yet.
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
      parentId: (json['originId'] is num ? json['originId'] as num : -1).toInt(), // null => -1 (for images parented directly to post)
      imageUrl: json['imageUrl'] as String?,
      postedAt: json['createdAt'] is String ? DateTime.tryParse(json['createdAt']) : null // backend currently doesn't send createdAt so it's nullable now
    );
  }
}