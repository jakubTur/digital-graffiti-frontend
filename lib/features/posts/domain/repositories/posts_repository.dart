import '../entities/post.dart';

abstract class PostsRepository {
  Future<void> postPost(Post post, int id);
  Future<List<Post>> getPosts();
  Future<List<Post>> getPostsByRadius(double latitude, double longitude, double radius);
}
