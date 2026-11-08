import '../datasources/posts_remote_ds.dart';
import '../../domain/repositories/posts_repository.dart';
import '../../domain/entities/post.dart';
import '../models/posts_request.dart';
import '../models/posts_response.dart';



class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource remoteDataSource;
  PostsRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> postPost(Post post, int id) async {
    final postRequest = PostRequest(
      userId: id,
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
  Post toPost(PostResponse response) {
    return Post(
      postedAt: response.postedAt,
      username: response.username,
      latitude: response.latitude,
      longitude: response.longitude,
      imageUrl: response.imageUrl
    );
  }
}
