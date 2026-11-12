import '../entities/post.dart';
import '../entities/drawing.dart';

abstract class PostsRepository {
  Future<void> postPost(Post post, int userId);
  Future<List<Post>> getPosts();
  Future<List<Post>> getPostsByRadius(double latitude, double longitude, double radius);
  Future<void> postDrawing(Drawing drawing);
  Future<List<Drawing>> getDrawingsByPostId(int postId);
}
