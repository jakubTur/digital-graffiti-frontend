import '../../domain/entities/drawing.dart';
import '../datasources/posts_remote_ds.dart';
import '../../domain/repositories/posts_repository.dart';
import '../../domain/entities/post.dart';
import '../models/drawing_request.dart';
import '../models/drawing_response.dart';
import '../models/posts_request.dart';
import '../models/posts_response.dart';



class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource remoteDataSource;
  PostsRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> postPost(Post post, int userId) async {
    final postRequest = PostRequest(
      userId: userId,
      latitude: post.latitude,
      longitude: post.longitude
    );
    await remoteDataSource.postPost(postRequest, post.imagePath!);
  }
  @override
  Future<List<Post>> getPosts() async {
    final response = await remoteDataSource.getPosts();
    return response.map(toPost).toList();
  }
  @override
  Future<List<Post>> getPostsByRadius(double latitude, double longitude, double radius) async {
    final response = await remoteDataSource.getPostsByRadius(latitude: latitude, longitude: longitude, radius: radius);
    return response.map(toPost).toList();
  }
  @override
  Future<void> postDrawing(Drawing drawing) async {
    final drawingRequest = DrawingRequest(
      userId: drawing.id,
      postId: drawing.post_id,
      parentId: drawing.parent_id
    );
    await remoteDataSource.postDrawing(drawingRequest, drawing.imagePath!);
  }
  @override
  Future<List<Drawing>> getDrawingsByPostId(int postId) async {
    final response = await remoteDataSource.getDrawingsByPostId(postId);
    return response.map(toDrawing).toList();
  }
  Post toPost(PostResponse response) {
    return Post(
      postedAt: response.postedAt,
      username: response.username,
      latitude: response.latitude,
      longitude: response.longitude,
      imageUrl: response.imageUrl
    );
  }
  Drawing toDrawing(DrawingResponse response) {
    return Drawing(
      id: response.id,
      username: response.username,
      parent_id: response.parentId,
      post_id: response.postId,
      imageUrl: response.imageUrl,
      postedAt: response.postedAt
    );
  }
}
