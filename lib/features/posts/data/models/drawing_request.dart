
class DrawingRequest {
  final int userId;
  final int postId;
  final int? parentId;
  DrawingRequest ({
    required this.userId,
    required this.postId,
    required this.parentId
  });
  Map<String, dynamic> toJson(){
    return {
      'userId' : userId,
      'postId' : postId,
      'originId' : parentId
    };
  }
}