import '../../../../../core/network/api_client.dart';
import '../models/drawing_request.dart';
import '../models/drawing_response.dart';
import '../models/posts_request.dart';
import '../models/posts_response.dart';

class PostsRemoteDataSource {
  final ApiClient api;
  PostsRemoteDataSource(this.api);

  Future<int> postPost(PostRequest post, String? imagePath) async {
    final response = await api.post('/api/posts/create', body: post.toJson());
    if (response is! Map || response['id'] is! num) {
      throw const FormatException(
        'Create post response does not contain a valid id',
      );
    }
    int postId = (response['id'] as num).toInt();
    if (imagePath != null) {
      await api.uploadFile(
        '/api/posts/$postId/photo',
        filePath: imagePath,
        fileField: 'file',
        expectedStatusCode: 200,
      );
    }
    return postId;
  }

  Future<PostResponse> getPost(int id) async {
    final response = await api.get('/api/posts/$id');
    return PostResponse.fromJson(response);
  }

  Future<List<PostResponse>> getPosts() async {
    final response = await api.get('/api/posts/all');
    return parsePosts(response);
  }

  Future<List<PostResponse>> getPostsByRadius({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    final response = await api.get(
      '/api/posts/nearby',
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radius': radius.toString(),
      },
    );
    return parsePosts(response);
  }

  Future<List<PostResponse>> getPostsByNickname(String nickname) async {
    final response = await api.get('/api/posts/nickname/$nickname');
    return parsePosts(response);
  }

  Future<void> postDrawing(DrawingRequest drawing, String imagePath) async {
    final response = await api.post(
      '/api/posts/drawings/add',
      body: drawing.toJson(),
      expectedStatusCode: 200,
    );
    if (response is! Map || response['id'] is! num) {
      throw const FormatException(
        'Create drawing response does not contain a valid id',
      );
    }
    int drawingId = (response['id'] as num).toInt();
    await api.uploadFile(
      '/api/posts/drawing/$drawingId/photo',
      filePath: imagePath,
      fileField: 'file',
      expectedStatusCode: 200,
    );
  }

  Future<List<DrawingResponse>> getDrawingsByPostId(int postId) async {
    final response = await api.get('/api/posts/drawings/$postId');
    return parseDrawings(response);
  }

  Future<void> deletePost(int id) async {
    await api.delete('/api/posts/$id', expectedStatusCode: 204);
  }

  Future<void> deleteDrawing(int id) async {
    await api.delete('/api/posts/drawings/$id', expectedStatusCode: 204);
  }

  List<PostResponse> parsePosts(dynamic response) {
    if (response is! List) {
      throw const FormatException('Get posts response is not a list');
    }
    return response
        .map(
          (item) =>
              PostResponse.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .where((post) => post.active)
        .toList();
  }

  List<DrawingResponse> parseDrawings(dynamic response) {
    if (response is! List) {
      throw const FormatException('Get drawings response is not a list');
    }
    return response
        .map(
          (item) =>
              DrawingResponse.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
}
