import '../../../../../core/network/api_client.dart';
import '../models/posts_request.dart';
import '../models/posts_response.dart';

class PostsRemoteDataSource {
  final ApiClient api;
  PostsRemoteDataSource(this.api);

  Future<void> postPost(PostRequest post, String imagePath) async {
    final response = await api.post('/api/posts/create', body: post.toJson());
    if (response is! Map || response['id'] is! num) {
      throw const FormatException('Create post response does not contain a valid id');
    }
    int postId = (response['id'] as num).toInt();
    await api.uploadFile(
      '/api/posts/$postId/photo',
      filePath: imagePath,
      fileField: 'file',
      expectedStatusCode: 200,
    );
  }
  Future<List<PostResponse>> getPosts() async {
    final response = await api.get('/api/posts/all');
    return parsePosts(response);
  }
  Future<List<PostResponse>> getPostsByRadius ({required double latitude, required double longitude, required double radius}) async {
    final response = await api.get(
      '/api/posts/nearby',
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString()
      },
    );
    return parsePosts(response);
  }
  List<PostResponse> parsePosts(dynamic response) {
    if (response is! List) {
      throw const FormatException('Get posts response is not a list');
    }
    return response.map((item) => PostResponse.fromJson(
          Map<String, dynamic>.from(item as Map),
        ),
    ).toList();
  }
}