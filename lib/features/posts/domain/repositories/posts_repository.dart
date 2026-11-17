import '../entities/drawing.dart';
import '../entities/post.dart';

abstract class PostsRepository {
  Future<int> postPost(Post post, int userId);
  Future<List<Post>> getPosts();
  Future<List<Post>> getPostsByRadius(
    double latitude,
    double longitude,
    double radius,
  );
  Future<void> postDrawing(Drawing drawing, int userId);
  Future<List<Drawing>> getDrawingsByPostId(int postId);
  Future<List<Post>> getPostsByNickname(String nickname);
}
