import 'dart:io';

import 'package:frontend/core/storage/auth_storage.dart';
import 'package:frontend/features/posts/domain/entities/drawing.dart';
import 'package:frontend/features/posts/domain/entities/post.dart';
import 'package:frontend/features/posts/domain/entities/post_draft.dart';
import 'package:frontend/features/posts/domain/repositories/posts_repository.dart';

/// Uploads post drafts to the backend as the logged in user.
class PostPublisher {
  const PostPublisher(this._postsRepository, this._authStorage);

  final PostsRepository _postsRepository;
  final AuthStorage _authStorage;

  Future<void> publish(PostDraft draft) async {
    final userId = await _authStorage.readUserId();
    if (userId == null) throw StateError('No logged in user.');
    final username = await _authStorage.readNickname() ?? '';

    // the backend client uploads images from disk
    final tempDirectory = await Directory.systemTemp.createTemp('post_upload');
    try {
      final imageFile = File('${tempDirectory.path}/drawing.png');
      await imageFile.writeAsBytes(draft.image);
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
      await _postsRepository.postDrawing(
        Drawing(
          username: username,
          parent_id: -1,
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
