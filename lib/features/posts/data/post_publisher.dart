import 'dart:io';
import 'dart:typed_data';

import 'package:frontend/core/storage/auth_storage.dart';
import 'package:frontend/features/posts/domain/entities/drawing.dart';
import 'package:frontend/features/posts/domain/entities/post.dart';
import 'package:frontend/features/posts/domain/entities/post_draft.dart';
import 'package:frontend/features/posts/domain/repositories/posts_repository.dart';

/// Uploads posts and drawings to the backend as the logged in user.
/// (this is a convenience class so other classes don't need to interact with the repository directly and can modify the posting methods safely)
class PostPublisher {
  const PostPublisher(this._postsRepository, this._authStorage);

  /// used to upload posts
  final PostsRepository _postsRepository;

  /// referenced here so that classes that want to post pictures don't need to know credentials
  final AuthStorage _authStorage;

  Future<void> publish(PostDraft draft) async {
    final (userId, username) = await _readUser();
    final postId = await _postsRepository.postPost(
      Post(
        postedAt: DateTime.now(),
        username: username,
        latitude: draft.location.latitude,
        longitude: draft.location.longitude,
        imagePath: draft.backgroundPath,
        imageUrl: null,
      ),
      userId,
    );
    await _uploadDrawing(
      draft.image,
      postId: postId,
      parentId: -1,
      userId: userId,
      username: username,
    );
  }

  Future<void> publishDrawing(
    Uint8List image, {
    required int postId,
    required int parentId,
  }) async {
    final (userId, username) = await _readUser();
    await _uploadDrawing(
      image,
      postId: postId,
      parentId: parentId,
      userId: userId,
      username: username,
    );
  }

  Future<(int, String)> _readUser() async {
    final userId = await _authStorage.readUserId();
    if (userId == null) throw StateError('No logged in user.');
    final username = await _authStorage.readNickname() ?? '';
    return (userId, username);
  }

  Future<void> _uploadDrawing(
    Uint8List image, {
    required int postId,
    required int parentId,
    required int userId,
    required String username,
  }) async {
    // the backend client uploads images from disk
    final tempDirectory = await Directory.systemTemp.createTemp('post_upload');
    try {
      final imageFile = File('${tempDirectory.path}/drawing.png');
      await imageFile.writeAsBytes(image);
      await _postsRepository.postDrawing(
        Drawing(
          username: username,
          parent_id: parentId,
          post_id: postId,
          imageUrl: null,
          imagePath: imageFile.path,
          postedAt: DateTime.now(),
        ),
        userId,
      );
    } finally {
      await tempDirectory.delete(recursive: true);
    }
  }
}
