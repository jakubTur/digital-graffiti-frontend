import 'package:flutter/material.dart';
import 'package:frontend/features/auth/data/datasources/auth_storage.dart';
import 'package:frontend/features/map/presentation/map_ui.dart';
import 'package:frontend/features/map/presentation/post_view_tree.dart';
import 'package:frontend/features/posts/domain/repositories/posts_repository.dart';
import 'package:frontend/features/posts/presentation/post_creation_flow.dart';

import 'display_map.dart';

/// Main screen of the app, containing the map and its model (aka state repository)
class MapScreen extends StatelessWidget {
  const MapScreen({
    super.key,
    required this.postsRepository,
    required this.authStorage,
    required this.postCreationFlow,
  });

  final PostsRepository postsRepository;
  final AuthStorage authStorage;
  final PostCreationFlow postCreationFlow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          DisplayMap(),
          MapUi(authStorage, postCreationFlow),
          PostViewTree(postCreationFlow),
        ],
      ),
    );
  }
}
