import 'dart:collection';

import 'package:flutter/material.dart';

import 'post_data.dart';

/// Data class encapsulating map state.
/// Made with help of state management tutorial: https://docs.flutter.dev/data-and-backend/state-mgmt/simple
/// Will be dependant on backend later.
class MapModel extends ChangeNotifier {
  final Map<int, PostData> _posts = {};

  UnmodifiableMapView<int, PostData> get posts => UnmodifiableMapView(_posts);

  /// Tempoerary post-creation method
  /// Call to upload a new post (keeping it locally on the frontend)
  /// TODO: replace with backend implementation
  void upload(PostData newPost) {
    var post_id = 1;
    while (_posts.containsKey(post_id)) {
      post_id++;
    }
    _posts[post_id] = newPost;
    notifyListeners();
  }

  /// TODO
  /// Call this method to add new posts (ex. when they're downloaded from the backend)
  void addMultiple(Map<int, PostData> newPosts) {}
}
